const {test}=require('node:test'),assert=require('node:assert/strict');
const {validateInput,validateSchedule}=require('./schedule');
const input={subjects:['Math'],hours:2};
test('input is bounded',()=>{assert.throws(()=>validateInput({subjects:[],hours:2}));assert.throws(()=>validateInput({...input,hours:999}));});
test('reject overlap, invented subjects and over budget',()=>{
  const s={subject:'Math',day:0,startMinute:420,durationMinutes:120};
  assert.equal(validateSchedule({sessions:[s]},input).length,1);
  assert.throws(()=>validateSchedule({sessions:[s,{...s,startMinute:440}]},input));
  assert.throws(()=>validateSchedule({sessions:[{...s,subject:'Other'}]},input));
  assert.throws(()=>validateSchedule({sessions:[s,{...s,day:1}]},input));
});
test('reject invalid times',()=>{assert.throws(()=>validateSchedule({sessions:[{subject:'Math',day:0,startMinute:1310,durationMinutes:60}]},input));});
