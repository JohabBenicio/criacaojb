alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
set lines 200 pages 3000
col terminal for a30
col userhost for a30
col os_username for a20
col username for a10
select
      os_username
    , userhost
    , username
    , terminal
    , timestamp
    , decode(returncode
        ,1017,'ORA-01017: invalid username/password; logon denied'
        ,28000,'ORA-28000: the account is locked') returncode
    , action_name
from dba_audit_trail
where action_name = 'LOGON' and returncode != 0 order by TIMESTAMP;


