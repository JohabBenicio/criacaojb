-- Desabilitar DIAGNOSTIC+TUNING
-- ALTER SYSTEM SET control_management_pack_access=NONE scope=both sid='*';

col "Node 1" for a30
col "Node 2" for a30
col name for a35
set lines 200 pages 2000
col value for a30
select distinct n1.name NAME,n1.value "Node 1",n2.value "Node 2" from gv$parameter n1, gv$parameter n2
where (upper(n1.name) in ('UNDO_TABLESPACE', 'CONTROL_MANAGEMENT_PACK_ACCESS','CPU_COUNT','DB_CACHE_SIZE','DB_FLASH_CACHE_SIZE','JOB_QUEUE_PROCESSES','LOG_BUFFER','OPEN_CURSORS','PARALLEL_MAX_SERVERS','PGA_AGGREGATE_TARGET','SEC_CASE_SENSITIVE_LOGON','SGA_MAX_SIZE','SGA_TARGET','SHARED_POOL_SIZE','CONTROL_MANAGEMENT_PACK_ACCESS','SERVICE_NAMES','DB_NAME','INSTANCE_NAME','DB_FILE_MULTIBLOCK_READ_COUNT','OPTIMIZER_ADAPTIVE_FEATURES','DB_FLASH_CACHE_SIZE','MEMORY_MAX_TARGET','MEMORY_TARGET')
or upper(n1.name) like '%PARALLEL%'
or upper(n1.name) like '%OPT%')
and n1.name=n2.name
and n1.inst_id=1
and n2.inst_id=2
order by 1;

