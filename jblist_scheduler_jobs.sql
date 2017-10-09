




select JOB_NAME,STATUS,LOG_DATE,ADDITIONAL_INFO from dba_scheduler_job_log where job_name like 'STATS%' and LOG_DATE > sysdate-7 order by 3 ;



EXEC DBMS_SCHEDULER.ENABLE('ITFPRD2.JOB_RUN_ETIQUETA_PTL_SP');

  SELECT enabled FROM dba_scheduler_jobs where job_name='JOB_RUN_ETIQUETA_PTL_SP';





col JOB_ACTION for a90
col REPEAT_INTERVAL for a50
set lines 200 pages 9999
col COMMENTS for a80
col OWNER for a15
SELECT owner, job_name, enabled,status, REPEAT_INTERVAL, JOB_ACTION FROM dba_scheduler_jobs where and b.status <> 'SUCCEEDED';








col JOB_ACTION for a90
col REPEAT_INTERVAL for a50
set lines 200 pages 9999
col COMMENTS for a80
col OWNER for a15
SELECT owner, job_name, enabled,state, REPEAT_INTERVAL, JOB_ACTION FROM dba_scheduler_jobs ;





col additional_info for a100
col job_action for a90
col repeat_interval for a50
set lines 200 pages 9999
col comments for a80
col owner for a15
select a.owner, a.job_name, a.enabled, b.status, a.repeat_interval, b.additional_info, a.job_action
from dba_scheduler_jobs a, dba_scheduler_job_log b where b.status <> 'SUCCEEDED' and a.job_name=b.job_name;





set lines 300 pages 2000 long 99999
col ADDITIONAL_INFO for a100
col job_name for a20
select JOB_NAME,STATUS,LOG_DATE,ADDITIONAL_INFO from dba_scheduler_job_log
where job_name like 'STATS%' and LOG_DATE > sysdate-10 and LOG_DATE < sysdate-5 order by 3 ;



select OWNER,JOB_NAME,RUNNING_INSTANCE,ELAPSED_TIME from DBA_SCHEDULER_RUNNING_JOBS where job_name like '%STATS%' ;



select JOB_NAME,STATUS,LOG_DATE,ADDITIONAL_INFO from dba_scheduler_job_log where job_name like 'STATS%' and LOG_DATE >= sysdate-1 order by 3 ;


select JOB_NAME,STATUS,LOG_DATE,ADDITIONAL_INFO from dba_scheduler_job_log where LOG_DATE >= sysdate-1 and job_name!='JOB_WMS_MATA_LOCK' order by 3 ;





select OWNER,JOB_NAME,RUNNING_INSTANCE,ELAPSED_TIME,SESSION_ID from DBA_SCHEDULER_RUNNING_JOBS where job_name !='JOB_WMS_MATA_LOCK';


conn logixprd/l1x9p



exec DBMS_SCHEDULER.STOP_JOB('ITFPRD.SCHEDULER_PRC_CANON_PEDIDO');



exec sys.dbms_scheduler.STOP_JOB(job_name=>'ITFPRD.SCHEDULER_PRC_CANON_PEDIDO', force=>true);



SCHEDULER_PRC_CANON_PEDIDO


col JOB_ACTION for a90
col REPEAT_INTERVAL for a50
set lines 200 pages 9999
col COMMENTS for a80
col OWNER for a15
SELECT owner, job_name, enabled, REPEAT_INTERVAL, JOB_ACTION FROM dba_scheduler_jobs where enabled='TRUE' and upper(job_name) like '%STAT%';



set lines 200 pages 9999
col COMMENTS for a80
SELECT owner, job_name, enabled FROM dba_scheduler_jobs;


col JOB_ACTION for a90
col REPEAT_INTERVAL for a50
set lines 200 pages 9999
col COMMENTS for a80
col OWNER for a15
SELECT owner, job_name, enabled, REPEAT_INTERVAL, JOB_ACTION FROM dba_scheduler_jobs where job_name='GATHER_STATS_JOB';







ORACLE_OCM.MGMT_CONFIG.collect_stats




SYS.SPC_GERA_ESTATISICA

select

set lines 200 pages 9999
col COMMENTS for a80
SELECT owner, program_name, enabled, COMMENTS FROM dba_scheduler_programs;




set lines 200 pages 9999
col COMMENTS for a80
SELECT program_name, enabled, COMMENTS FROM dba_scheduler_programs;



set lines 200 pages 9999
col COMMENTS for a80
SELECT owner, job_name, enabled FROM dba_scheduler_jobs where enabled='TRUE';







exec DBMS_SCHEDULER.DISABLE();





set lines 200 pages 9999
col COMMENTS for a80
SELECT owner, job_name, enabled FROM dba_scheduler_jobs where owner='PERFSTAT';





exec DBMS_SCHEDULER.DISABLE('GATHER_STATSPACK_SNAP');
exec DBMS_SCHEDULER.DISABLE('PURGE_STATSPACK_SNAP');

PERFSTAT                       GATHER_STATSPACK_SNAP          TRUE
PERFSTAT                       PURGE_STATSPACK_SNAP           TRUE


OWNER                          JOB_NAME                       ENABL
------------------------------ ------------------------------ -----
PERFSTAT                       GATHER_STATSPACK_SNAP          FALSE
PERFSTAT                       PURGE_STATSPACK_SNAP           FALSE




user_scheduler_programs

OWNER                          PROGRAM_NAME                   ENABL
------------------------------ ------------------------------ -----
SYS                            PURGE_LOG_PROG                 TRUE
SYS                            GATHER_STATS_PROG              TRUE
SYS                            AUTO_SPACE_ADVISOR_PROG        TRUE
SYS                            FILE_WATCHER_PROGRAM           TRUE
SYS                            ORA$AGE_AUTOTASK_DATA          TRUE
SYS                            HS_PARALLEL_SAMPLING           TRUE
SYS                            AQ$_PROPAGATION_PROGRAM        TRUE
SYS                            AUTO_SQL_TUNING_PROG           TRUE
SYS                            BSLN_MAINTAIN_STATS_PROG       TRUE
SYS                            JDM_BUILD_PROGRAM              TRUE
SYS                            JDM_TEST_PROGRAM               TRUE
SYS                            JDM_SQL_APPLY_PROGRAM          TRUE
SYS                            JDM_EXPORT_PROGRAM             TRUE
SYS                            JDM_IMPORT_PROGRAM             TRUE
SYS                            JDM_XFORM_PROGRAM              TRUE
SYS                            JDM_PREDICT_PROGRAM            TRUE
SYS                            JDM_EXPLAIN_PROGRAM            TRUE
SYS                            JDM_PROFILE_PROGRAM            TRUE
SYS                            JDM_XFORM_SEQ_PROGRAM          TRUE





col REPEAT_INTERVAL for a80
col owner for a12
set lines 200 pages 2000

SELECT owner, job_name, enabled, to_char(START_DATE,'dd/mm/yyyy hh24:mi:ss') START_DATE, to_char(LAST_START_DATE,'dd/mm/yyyy hh24:mi:ss') LAST_START_DATE,REPEAT_INTERVAL
FROM dba_scheduler_jobs where enabled='TRUE';







Name                              Type
 -------------------------------- ----------------------------------------------------------------------------
 OWNER                            VARCHAR2(30)
 JOB_NAME                         VARCHAR2(30)
 JOB_SUBNAME                      VARCHAR2(30)
 JOB_STYLE                        VARCHAR2(11)
 JOB_CREATOR                      VARCHAR2(30)
 CLIENT_ID                        VARCHAR2(64)
 GLOBAL_UID                       VARCHAR2(32)
 PROGRAM_OWNER                    VARCHAR2(4000)
 PROGRAM_NAME                     VARCHAR2(4000)
 JOB_TYPE                         VARCHAR2(16)
 JOB_ACTION                       VARCHAR2(4000)
 NUMBER_OF_ARGUMENTS              NUMBER
 SCHEDULE_OWNER                   VARCHAR2(4000)
 SCHEDULE_NAME                    VARCHAR2(4000)
 SCHEDULE_TYPE                    VARCHAR2(12)
 START_DATE                       TIMESTAMP(6) WITH TIME ZONE
 REPEAT_INTERVAL                  VARCHAR2(4000)
 EVENT_QUEUE_OWNER                VARCHAR2(30)
 EVENT_QUEUE_NAME                 VARCHAR2(30)
 EVENT_QUEUE_AGENT                VARCHAR2(256)
 EVENT_CONDITION                  VARCHAR2(4000)
 EVENT_RULE                       VARCHAR2(65)
 FILE_WATCHER_OWNER               VARCHAR2(65)
 FILE_WATCHER_NAME                VARCHAR2(65)
 END_DATE                         TIMESTAMP(6) WITH TIME ZONE
 JOB_CLASS                        VARCHAR2(30)
 ENABLED                          VARCHAR2(5)
 AUTO_DROP                        VARCHAR2(5)
 RESTARTABLE                      VARCHAR2(5)
 STATE                            VARCHAR2(15)
 JOB_PRIORITY                     NUMBER
 RUN_COUNT                        NUMBER
 MAX_RUNS                         NUMBER
 FAILURE_COUNT                    NUMBER
 MAX_FAILURES                     NUMBER
 RETRY_COUNT                      NUMBER
 LAST_START_DATE                  TIMESTAMP(6) WITH TIME ZONE
 LAST_RUN_DURATION                INTERVAL DAY(9) TO SECOND(6)
 NEXT_RUN_DATE                    TIMESTAMP(6) WITH TIME ZONE
 SCHEDULE_LIMIT                   INTERVAL DAY(3) TO SECOND(0)
 MAX_RUN_DURATION                 INTERVAL DAY(3) TO SECOND(0)
 LOGGING_LEVEL                    VARCHAR2(11)
 STOP_ON_WINDOW_CLOSE             VARCHAR2(5)
 INSTANCE_STICKINESS              VARCHAR2(5)
 RAISE_EVENTS                     VARCHAR2(4000)
 SYSTEM                           VARCHAR2(5)
 JOB_WEIGHT                       NUMBER
 NLS_ENV                          VARCHAR2(4000)
 SOURCE                           VARCHAR2(128)
 NUMBER_OF_DESTINATIONS           NUMBER
 DESTINATION_OWNER                VARCHAR2(128)
 DESTINATION                      VARCHAR2(128)
 CREDENTIAL_OWNER                 VARCHAR2(30)
 CREDENTIAL_NAME                  VARCHAR2(30)
 INSTANCE_ID                      NUMBER
 DEFERRED_DROP                    VARCHAR2(5)
 ALLOW_RUNS_IN_RESTRICTED_MODE    VARCHAR2(5)
 COMMENTS                         VARCHAR2(240)
 FLAGS                            NUMBER





select job_name, job_type, program_name, schedule_name, job_class from dba_scheduler_jobs where job_name = 'GATHER_STATS_JOB';
select job_name, job_type, program_name, schedule_name, job_class from dba_scheduler_jobs   where job_name='GATHER_STATS_JOB';





select PROGRAM_ACTION  from dba_scheduler_programs  where PROGRAM_NAME = 'GATHER_STATS_PROG';








set lines 300 pages 2000 long 99999
col ADDITIONAL_INFO for a100
col job_name for a20
select JOB_NAME,STATUS,LOG_DATE,ADDITIONAL_INFO from dba_scheduler_job_log
where job_name like 'STATS%' and LOG_DATE > sysdate-2 order by 3 ;






select * from DBA_SCHEDULER_GLOBAL_ATTRIBUTE where ATTRIBUTE_NAME='SCHEDULER_DISABLED';

SQL> select * from DBA_SCHEDULER_GLOBAL_ATTRIBUTE where ATTRIBUTE_NAME='SCHEDULER_DISABLED';

ATTRIBUTE_NAME      VALUE
------------------- ------
SCHEDULER_DISABLED  TRUE






col additional_info for a95
col job_action for a20
col repeat_interval for a70
col JOB_NAME for a8
col status for a10

set lines 300 pages 9999
col comments for a80
col owner for a15
select a.owner
     , a.job_name
     , a.enabled
     , b.status
     , a.repeat_interval
--     , b.additional_info
     , b.error#
     , b.log_date
--     , a.job_action
from dba_scheduler_jobs a, ALL_SCHEDULER_JOB_RUN_DETAILS b where a.job_name=b.job_name and a.job_name='MUL_PRC' order by log_date;



select distinct status from ALL_SCHEDULER_JOB_RUN_DETAILS;


col additional_info for a100
col job_action for a90
col repeat_interval for a50
alter session set nls_date_format='dd/mm/yyyy hh24:mi';
set lines 200 pages 9999
col comments for a80
col owner for a15
select job_name, to_char(log_date,'dd/mm/yyyy hh24:mi')
from dba_scheduler_job_log where status = 'SUCCEEDED' and job_name like 'STATS_%' order by log_date;















col job_name for a27
SELECT job_name, session_id, running_instance, elapsed_time, cpu_used FROM dba_scheduler_running_jobs;



JOB_HOTLISTINTELLIGENT






set lines 200 pages 9999
col COMMENTS for a80
col JOB_ACTION for a80

SELECT owner, job_name, enabled,JOB_ACTION FROM dba_scheduler_jobs where enabled='TRUE' and job_name='JOB_HOTLISTINTELLIGENT';



OWNER        JOB_NAME                    ENABL JOB_ACTION
------------ --------------------------- ----- --------------------------------------------------------------------------------
MERCURY      JOB_HOTLISTINTELLIGENT      TRUE

DECLARE V_RESULT NUMBER; V_RESULT_MSG VARCHAR2(500);
BEGIN MERCURY.UDP_HOTLISTINTELLIGENT(13001, V_RESULT, V_RESULT_MSG, 20000);
END;















col additional_info for a100
col job_action for a90
col repeat_interval for a50
alter session set nls_date_format='dd/mm/yyyy hh24:mi';
set lines 200 pages 9999
col comments for a80
col owner for a15

select job_name, max(to_date(trunc(log_date))) from dba_scheduler_job_log where job_name like 'STATS_%' group by job_name;
select job_name, max(log_date),min(log_date) from dba_scheduler_job_log where job_name like 'STATS_%' group by job_name;

select min(log_date),max(log_date) from dba_scheduler_job_log where job_name like 'STATS_%';




