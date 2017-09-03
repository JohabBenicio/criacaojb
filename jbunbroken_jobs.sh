vi /tmp/jbunbroken_jobs.sh
i

~/.bash_profile
export ORACLE_SID=WIS

BANCO=$(ps -ef | grep smon | grep $ORACLE_SID 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$ORACLE_SID( |$)" | wc -l)

if [ "$BANCO" -eq "0" ]; then
   echo "Banco nao esta iniciado" ;
   exit 1;
fi

sqlplus /nolog <<EOF>/tmp/unbroken_jobs.log
conn / as sysdba

define v_job='38,58,93';
set serveroutput on
DECLARE
v_brok varchar2(3);
BEGIN

    dbms_output.put_line(rpad('JOB',7,' ')||chr(32)||'BLOQUEADO');
    dbms_output.put_line(rpad('-',7,'-')||chr(32)||rpad('-',9,'-'));

  for x in (select job, broken from dba_jobs where job in (&&v_job) and broken='Y')LOOP
    dbms_output.put_line(rpad(x.job,7,' ')||chr(32)||x.broken);
    DBMS_IJOB.BROKEN(x.job, FALSE);
    select broken into v_brok from dba_jobs where job=x.job;
    dbms_output.put_line(rpad(x.job,7,' ')||chr(32)||v_brok||chr(10));
commit;
  END LOOP;

END;
/
disconnect;
exit;
EOF
