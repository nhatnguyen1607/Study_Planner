const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const {initializeTestEnvironment,assertFails,assertSucceeds}=require('@firebase/rules-unit-testing');
const {doc,setDoc,getDoc,getDocs,collection,updateDoc,writeBatch,serverTimestamp,Timestamp}=require('firebase/firestore');
const meta=()=>({ownerId:'alice',schemaVersion:1,revision:1,createdAt:serverTimestamp(),updatedAt:serverTimestamp()});
test('Firestore rules enforce UID, revisions, parent relation and atomic calendar writes',{skip:!process.env.FIRESTORE_EMULATOR_HOST},async t=>{
  const env=await initializeTestEnvironment({projectId:'demo-study-planner',firestore:{rules:fs.readFileSync(require('node:path').join(__dirname,'../firestore.rules'),'utf8')}});
  try{
    const alice=env.authenticatedContext('alice',{email:'alice@example.com'}).firestore();
    const bob=env.authenticatedContext('bob').firestore(),anon=env.unauthenticatedContext().firestore();
    const task=doc(alice,'user/alice/tasks/task');
    await t.test('create task, preserve extension, reject stale writes',async()=>{
      await assertSucceeds(setDoc(task,{...meta(),title:'Task',notes:'',completed:false,archived:false,extensions:{custom:true}}));
      await assertSucceeds(updateDoc(task,{completed:true,revision:2,updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(task,{completed:false,revision:2,updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(task,{ownerId:'bob',revision:3,updatedAt:serverTimestamp()}));
    });
    await t.test('deny anonymous and other UID for all collections',async()=>{
      for(const kind of ['plans','sessions','goals','tasks','notifications','activities','settings']){
        await env.withSecurityRulesDisabled(async c=>setDoc(doc(c.firestore(),`user/alice/${kind}/isolation`),{ownerId:'alice',schemaVersion:1,revision:1}));
        await assertSucceeds(getDoc(doc(alice,`user/alice/${kind}/isolation`)));
        await assertFails(getDoc(doc(bob,`user/alice/${kind}/isolation`)));
        await assertFails(getDocs(collection(bob,`user/alice/${kind}`)));
        await assertFails(getDoc(doc(anon,`user/alice/${kind}/isolation`)));
        await assertFails(setDoc(doc(bob,`user/alice/${kind}/forged`),{...meta(),title:'Forged'}));
      }
    });
    const plan={...meta(),title:'Plan',objective:'',source:'manual',status:'active',subjects:['Math'],startAt:Timestamp.fromDate(new Date('2026-11-01')),endAt:Timestamp.fromDate(new Date('2026-11-28')),weeklyHours:3,archived:false};
    const session={...meta(),planId:'p',title:'Math',subject:'Math',startAt:Timestamp.fromDate(new Date('2026-11-02T09:00:00Z')),endAt:Timestamp.fromDate(new Date('2026-11-02T10:00:00Z')),status:'scheduled',actualMinutes:0,rating:0,notes:'',location:'',materials:'',archived:false};
    await t.test('plan and sessions are committed together with calendar lock',async()=>{
      const batch=writeBatch(alice);
      batch.set(doc(alice,'user/alice/settings/calendar'),meta());
      batch.set(doc(alice,'user/alice/plans/p'),plan);
      batch.set(doc(alice,'user/alice/sessions/s'),session);
      await assertSucceeds(batch.commit());
      assert.equal((await getDoc(doc(alice,'user/alice/sessions/s'))).data().planId,'p');
    });
    await t.test('reject missing parent, invalid duration and writes without calendar lock',async()=>{
      await assertFails(setDoc(doc(alice,'user/alice/sessions/without-lock'),session));
      for(const change of [{planId:'missing'},{endAt:Timestamp.fromDate(new Date('2026-11-02T16:00:00Z'))}]){
        const batch=writeBatch(alice);batch.update(doc(alice,'user/alice/settings/calendar'),{revision:2,updatedAt:serverTimestamp()});
        batch.set(doc(alice,'user/alice/sessions/invalid'),{...session,...change});await assertFails(batch.commit());
      }
    });
    await t.test('goals validate progress; notification creation remains server-only',async()=>{
      const goal={...meta(),title:'Goal',description:'',category:'Math',unit:'lessons',baseline:0,current:0,target:10,deadline:Timestamp.fromDate(new Date('2026-12-01')),milestones:[],notes:'',rating:0,archived:false};
      await assertSucceeds(setDoc(doc(alice,'user/alice/goals/g'),goal));
      await assertFails(updateDoc(doc(alice,'user/alice/goals/g'),{current:11,revision:2,updatedAt:serverTimestamp()}));
      await assertFails(setDoc(doc(alice,'user/alice/notifications/n'),{...meta(),title:'Fake'}));
    });
    await t.test('AI confirmation creates dated sessions once and cannot use another UID draft',async()=>{
      process.env.GCLOUD_PROJECT='demo-study-planner';
      const functions=require('./index');
      const admin=require('firebase-admin/firestore').getFirestore();
      const date=new Date(Date.now()+7*86400000).toISOString().substring(0,10);
      await admin.doc('user/charlie/aiDrafts/draft-safe').set({input:{subjects:['Math'],hours:1},sessions:[{subject:'Math',day:0,startMinute:420,durationMinutes:60}]});
      const request={auth:{uid:'charlie'},data:{draftId:'draft-safe',startDate:date,timezoneOffsetMinutes:420}};
      await functions.confirmSchedule.run(request);await functions.confirmSchedule.run(request);
      const saved=await admin.collection('user/charlie/sessions').get();
      assert.equal(saved.size,4);assert.equal((await admin.collection('user/charlie/plans').get()).size,1);
      assert.ok(saved.docs.every(d=>d.data().ownerId==='charlie'&&d.data().planId==='draft-safe'));
      await assert.rejects(functions.confirmSchedule.run({...request,auth:{uid:'bob'}}),e=>e.code==='not-found');
      await admin.doc('user/charlie/aiDrafts/draft-overlap').set({input:{subjects:['Math'],hours:1},sessions:[{subject:'Math',day:0,startMinute:420,durationMinutes:60}]});
      await assert.rejects(functions.confirmSchedule.run({...request,data:{...request.data,draftId:'draft-overlap'}}),e=>e.code==='already-exists');
      assert.equal((await admin.collection('user/charlie/plans').get()).size,1);
      const before={data:()=>undefined},after={data:()=>({ownerId:'charlie',schemaVersion:1,revision:1,title:'Plan'})};
      const event={params:{uid:'charlie',id:'draft-safe'},data:{before,after}};
      await functions.plansActivity.run(event);await functions.plansActivity.run(event);
      assert.equal((await admin.collection('user/charlie/notifications').get()).size,1);
      assert.equal((await admin.collection('user/charlie/activities').get()).size,1);
    });
  }finally{await env.cleanup();}
});
