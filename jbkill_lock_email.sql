



#!/bin/bash
. ~/.bash_profile

LOGKILL=/tmp/kill_lock_tmp.log
LOG=/tmp/kill_lock.log

export ORACLE_SID=$1

sqlplus -S /nolog <<EOF>$LOGKILL
conn / as sysdba
set echo on
set feedback off
set serveroutput on
set lines 200 pages 9999

declare
vtime varchar2(90):=900;
KILL varchar2(1):='N';
vdata varchar2(20);
valid varchar2(9);

	cursor c1 is
      select s.sid,s.serial#,s.program,s.machine,s.osuser,s.username,s.status,l2.ctime from v\$session s, v\$lock l1, v\$lock l2
      where s.username is not null 
      and s.username not in ('SYS','SYSTEM') 
      and s.type='USER' 
      and s.status = 'INACTIVE' 
      and s.sid=l1.sid 
      and l1.block>0
      and l1.id1=l2.id1
      and l1.id2=l2.id2
      and l2.block=0
      and l2.ctime>vtime;

begin

select count(*) into valid from v\$session s, v\$lock l1, v\$lock l2
      where s.username is not null 
      and s.username not in ('SYS','SYSTEM') 
      and s.type='USER' 
      and s.status = 'INACTIVE' 
      and s.sid=l1.sid 
      and l1.block>0
      and l1.id1=l2.id1
      and l1.id2=l2.id2
      and l2.block=0
      and l2.ctime>vtime;

    if valid = 0 then
    	dbms_output.put_line(1);
    else
	select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into vdata from dual;
	dbms_output.put_line(' HORARIO DA ANALISE: '||vdata||chr(10));
	for x in c1 loop
	   	dbms_output.put_line(' OWNER S.O:............ '||lower(x.osuser));
	   	dbms_output.put_line(' MACHINE:.............. '||lower(x.machine));
	   	dbms_output.put_line(' OWNER DB:............. '||lower(x.username));
	   	dbms_output.put_line(' STATUS OWNER DB:...... '||lower(x.status));
	   	dbms_output.put_line(' PROGRAM USADO:........ '||lower(x.program));
	   	dbms_output.put_line(' TEMPO DE LOCK:........ '||lower(x.ctime) || ' segundos'||chr(10)||chr(10));
	   	if KILL = 'Y' then
		    execute immediate 'alter system kill session '''||x.sid||','||x.serial#||''' immediate';
		end if;
   end loop;
   end if;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
end;
/

quit

EOF


if [ "$(cat $LOGKILL)" != "1" ]; then

echo -e "\n\n">>$LOG
cat $LOGKILL>>$LOG

TO="johab@teor.inf.br,fernando.vidaletti@teor.inf.br"
sendEmail -f dbmonitor@teor.inf.br -t $TO -s smtp.teor.inf.br:587 -u "Analise de Lock." -o message-file="$LOGKILL" -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"

fi



