



ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -vi "asm\|oracle" | while read instance_db
do

export ORAENV_ASK=NO ; ORACLE_SID=$instance_db ; . oraenv; export ORAENV_ASK=YES

sqlplus -S / as sysdba << EOF
select instance_name from v\$instance;
show parameter sga_
EOF

done


set serveroutput on

declare
x varchar2(15);
begin
select VALUE into x from V$PARAMETER where name='sga_max_size';
if x = 0 then
	select VALUE into x from V$PARAMETER where name='sga_target';
end if;
dbms_output.put_line(x/1024/1024/2);
end;
/



[oracle@srvbanco [orajr] log]$ cat /proc/meminfo  | grep -i hug
HugePages_Total:  3005
HugePages_Free:     93
HugePages_Rsvd:     76
Hugepagesize:     2048 kB


[oracle@srvbanco [orajr] log]$ cat /etc/sysctl.conf | grep -i hug
vm.nr_hugepages=3005


2915















ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -vi "asm\|oracle" | while read instance_db
do
export ORACLE_SID=$instance_db
sqlplus -S / as sysdba <<EOF
set feedback off
set serveroutput on
set lines 200
select instance_name,status from v\$instance;
declare
x varchar2(15);
begin

select VALUE into x from V\$PARAMETER where name='sga_max_size';
if x = 0 then
select VALUE into x from V\$PARAMETER where name='sga_target';
end if;
dbms_output.put_line(x/1024/1024/2||'     '||x/1024/1024);
end;
/
EOF

done











ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -vi "asm\|oracle" | while read instance_db
do
export ORACLE_SID=$instance_db

sqlplus -S / as sysdba <<EOF>/tmp/sga.log
set feedback off
set serveroutput on
declare
x varchar2(15);
begin
select VALUE into x from V\$PARAMETER where name='sga_max_size';
if x = 0 then
select VALUE into x from V\$PARAMETER where name='sga_target';
end if;
dbms_output.put_line(x/1024/1024/2);
end;
/
EOF
done











ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -vi "asm\|oracle" | while read instance_db
do
export ORACLE_SID=$instance_db
sqlplus -S / as sysdba <<EOF
set feedback off
set serveroutput on
set lines 200
select instance_name,status from v\$instance;
show parameter sga_
EOF

done

