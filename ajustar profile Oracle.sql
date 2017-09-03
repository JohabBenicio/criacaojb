
set lines 200 pages 300
select * from dba_profiles where profile='DEFAULT';

PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 10
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 180
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD UNLIMITED
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD UNLIMITED
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD NULL
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 1
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 7


alter profile DEFAULT limit PASSWORD_LOCK_TIME 3;
alter profile DEFAULT limit PASSWORD_LOCK_TIME unlimited;

select * from dba_profiles where profile='DEFAULT';

PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 10
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 180
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD UNLIMITED
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD UNLIMITED
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD NULL
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD UNLIMITED
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 7



CARACT=1

for a1 in {a..z}
do
	for a2 in {A..Z}
	do
		for a3 in {1..9}
		do
   			for a4 in {a..z}
			do
				for a5 in {A..Z}
				do
					"$CARACT"
				done
			done
		done
	done
done




set lines 200 pages 200
select 'alter user '|| name ||' identified by values ''' || nvl2(spare4, spare4 || ';' || password , password) || ''';' as stmt from sys.user$ where coalesce(spare4, password) is not null;
'

SYS                            8A8F025737A9097A

ORACLE	ORACLE	38E38619A12E0257