

-rw-rw---- 1 oracle oinstall 43023489 Nov 19 11:41 ./SENIOR_HOMOLOG/bdump/alert_SENIORH2.log
-rw-rw---- 1 oracle oinstall 62688 Nov 19 11:41 ./QUALISH/bdump/alert_QUALISH2.log
-rw-rw---- 1 oracle oinstall 56231871 Nov 19 11:41 ./MAXYS_HOMOLOG/bdump/alert_MAXYSH2.log


MAXYSH2, QUALISH2 e SENIORH2.




 ps -ef | grep smon | grep MAXYSH


show parameter db_unique_name

srvctl status database -d MAXYS_HOMOLOG

srvctl start instance -d MAXYS_HOMOLOG -i MAXYSH2




find $ORACLE_BASE/admin -name alert* | while read alert
do
tail -600 $alert | grep -1  "Starting ORACLE instance\|shutdown" | grep "Nov 19" | wc -l | while read star
do
if [ $star -eq 0 ]; then
ls -l $alert | grep -v 201 | grep Nov
fi
done
done








