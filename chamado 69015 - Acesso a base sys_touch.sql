Por favor, liberar o acesso a base sys_touch para os usuários SDMOURA e PBGONCALVES.

Att,
Eric



Usuário: SDMOURA
Schema: SYS_TOUCH


########################################################################################################################

1) - Com  sysdba criar o usuário caso não exista :

Obs: Se o usuário existir ir direto para o passo 2.

Exemplo:

CREATE USER SDMOURA IDENTIFIED BY S1#mnB57Y6t DEFAULT TABLESPACE "USERS" TEMPORARY TABLESPACE  "TEMP";
ALTER USER SDMOURA PASSWORD EXPIRE;

2)  Conceder grant HSL_STAFF_TI para o usuário.

GRANT HSL_STAFF_TI TO SDMOURA;


3) Conectar com usuário HSLSYS

conn hslsys/kmod77ou90

4) Executar a procedure de autogrant.

EXEC OLC$ADMIN.AUTOMANAGEMENT_BY_USER ('SYS_TOUCH', 'SDMOURA', OLC$ADMIN.OPERATION_ALLOW, FALSE);



########################################################################################################################

Usuário: SDMOURA
Schema: PBGONCALVES

########################################################################################################################

2)  Conceder grant HSL_STAFF_TI para o usuário.

GRANT HSL_STAFF_TI TO PBGONCALVES;


3) Conectar com usuário HSLSYS

conn hslsys/kmod77ou90

4) Executar a procedure de autogrant.


EXEC OLC$ADMIN.AUTOMANAGEMENT_BY_USER ('SYS_TOUCH', 'PBGONCALVES', OLC$ADMIN.OPERATION_ALLOW, FALSE);

