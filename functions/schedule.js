function validateInput(data) {
  if(!data||!Array.isArray(data.subjects)||data.subjects.length<1||data.subjects.length>6||
    !data.subjects.every(v=>typeof v==='string'&&v.trim().length>0&&v.length<=80)||
    !Number.isInteger(data.hours)||data.hours<1||data.hours>28)throw Error('invalid-input');
  return {subjects:[...new Set(data.subjects.map(v=>v.trim()))],hours:data.hours};
}
function validateSchedule(data,input){
  if(!Array.isArray(data?.sessions)||data.sessions.length<1||data.sessions.length>56)throw Error('invalid-output');
  const sessions=data.sessions.map(s=>{
    if(!input.subjects.includes(s.subject)||!Number.isInteger(s.day)||s.day<0||s.day>6||
      !Number.isInteger(s.startMinute)||s.startMinute<420||
      !Number.isInteger(s.durationMinutes)||s.durationMinutes<15||s.durationMinutes>120||
      s.startMinute+s.durationMinutes>1320)throw Error('invalid-session');
    return {subject:s.subject,day:s.day,startMinute:s.startMinute,durationMinutes:s.durationMinutes};
  }).sort((a,b)=>a.day-b.day||a.startMinute-b.startMinute);
  if(sessions.reduce((n,s)=>n+s.durationMinutes,0)>input.hours*60)throw Error('over-budget');
  for(let i=1;i<sessions.length;i++){
    const a=sessions[i-1],b=sessions[i];
    if(a.day===b.day&&a.startMinute+a.durationMinutes>b.startMinute)throw Error('overlap');
  }
  return sessions;
}
module.exports={validateInput,validateSchedule};
