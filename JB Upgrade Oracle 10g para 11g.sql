Upgrade Oracle 10g para 11g.

Caso encontre o erro:

SELECT TO_NUMBER('MUST_HAVE_RUN_PRE-UPGRADE_TOOL_FOR_TIMEZONE')
   *
   ERROR at line 1:
   ORA-01722: invalid number

Seguir o note: Master Note : ORA-1722 Errors during Upgrade (Doc ID 1466464.1)


1) If the registry$database table does not get created by the Pre-Upgrade Script,then it may be created using the below SQL statement:

CREATE TABLE registry$database(
    platform_id   NUMBER,
    platform_name VARCHAR2(101),
    edition       VARCHAR2(30),
    tz_version    NUMBER
    );


 2) Then manually insert the Platform DST Patch information using the below SQL statement:

INSERT into registry$database
    (platform_id, platform_name, edition, tz_version)
VALUES ((select platform_id from v$database),
       (select platform_name from v$database),
        NULL,
       (select version from v$timezone_file));


3) Commit the above statement

SQL> commit;

4) Query the newly created Table for the accurate results.

set lines 200
col PLATFORM_NAME for a20
select * from sys.registry$database;

PLATFORM_ID PLATFORM_NAME  EDITION      TZ_VERSION
----------- -------------------- ------------------------------ ----------
   13 Linux x86 64-bit
   13 Linux x86 64-bit            14


OC>#######################################################################
DOC>#######################################################################
DOC>   The following error is generated if the pre-upgrade tool has not been
DOC>   run in the old ORACLE_HOME home prior to upgrading a pre-11.2 database:
DOC>
DOC>   SELECT TO_NUMBER('MUST_HAVE_RUN_PRE-UPGRADE_TOOL_FOR_TIMEZONE')
DOC>         *
DOC>    ERROR at line 1:
DOC>    ORA-01722: invalid number
DOC>
DOC>   o Action:
DOC>     Shutdown database ("alter system checkpoint" and then "shutdown abort").
DOC>     Revert to the original oracle home and start the database.
DOC>     Run pre-upgrade tool against the database.
DOC>     Review and take appropriate actions based on the pre-upgrade
DOC>     output before opening the datatabase in the new software version.
DOC>
DOC>#######################################################################
DOC>#######################################################################
DOC>#

Session altered.


Table created.


Table altered.

  ((SELECT tz_version from registry$database) is null)
          *
ERROR at line 8:
ORA-01427: single-row subquery returns more than one row


5) Delete do dado nulo

delete from registry$database where tz_version is null;



@?/rdbms/admin/catupgrd.sql
@?/rdbms/admin/utlrp.sql
@?/rdbms/admin/utlu112s.sql












