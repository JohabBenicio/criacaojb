
## ####################################################################################
##  1. CRIAR UMA NOVA TABLESPACE PARA ARMAZENAR OS OBJETOS DA AUDITORIA:
## ####################################################################################

create tablespace AUDITDB datafile '+DGDATA' size 64m autoextend on next 64m maxsize 8g;


## ####################################################################################
##  2. CRIAR UM SCHEMA 
## ####################################################################################

CREATE USER AUDTUSER IDENTIFIED BY audtuser DEFAULT TABLESPACE AUDITDB;

GRANT CONNECT,RESOURCE TO AUDTUSER;

## ####################################################################################
##  3. CRIAR AS TABELAS
## ####################################################################################

DROP TABLE AUDTUSER.AUDIT_LOGIN CASCADE CONSTRAINTS;

CREATE TABLE AUDTUSER.AUDIT_LOGIN (
	ID_LOGIN 	NUMBER CONSTRAINT PK_AUDIT_LOGIN PRIMARY KEY,
	OSUSER		VARCHAR2(50),
	USERNAME	VARCHAR2(30),
	MACHINE 	VARCHAR2(30),
	PROGRAM 	VARCHAR2(50)
);




DROP TABLE AUDTUSER.AUDIT_TIME;

CREATE TABLE AUDTUSER.AUDIT_TIME (
	ID_LOGIN	NUMBER,
	LOGIN_TIME	VARCHAR2(20)
);

ALTER TABLE AUDTUSER.AUDIT_TIME ADD CONSTRAINT FK_LOGIN_TIME FOREIGN KEY (ID_LOGIN) REFERENCES AUDTUSER.AUDIT_LOGIN (ID_LOGIN);

## ####################################################################################
##  4. CRIAR UMA SEQUENCE
## ####################################################################################

DROP SEQUENCE SEQ_AUDIT_LOGIN;

CREATE SEQUENCE SEQ_AUDIT_LOGIN
MINVALUE 1
MAXVALUE 9999999999
START WITH 1
INCREMENT BY 1
NOCACHE
CYCLE;

-- SELECT SEQ_AUDIT_LOGIN.NEXTVAL FROM DUAL;




## ####################################################################################
##  5. CRIAR TRIGGER
## ####################################################################################


CREATE OR REPLACE TRIGGER TRG_LOGON_AUDUSER
  AFTER LOGON ON DATABASE
DECLARE
	VID_LOGIN NUMBER;
	VHOST_NAME varchar2(64);
BEGIN

select HOST_NAME into VHOST_NAME from v$instance;

FOR X IN (SELECT USERNAME,OSUSER, MACHINE, PROGRAM FROM V$SESSION 
	WHERE USERNAME IS NOT NULL 
	AND OSUSER IS NOT NULL 
	and audsid = USERENV('SESSIONID') 
	AND audsid != 0 
	AND ROWNUM = 1)LOOP
		if x.PROGRAM like '%'||VHOST_NAME||'%' and x.USERNAME='SYS' then
		NULL;
		ELSE
			SELECT count(ID_LOGIN) into VID_LOGIN FROM AUDTUSER.AUDIT_LOGIN WHERE USERNAME=X.USERNAME AND OSUSER=X.OSUSER AND MACHINE=X.MACHINE AND PROGRAM=X.PROGRAM;
			if VID_LOGIN = 0 then
				insert into AUDTUSER.AUDIT_LOGIN (ID_LOGIN,OSUSER,USERNAME,MACHINE,PROGRAM)
					values (SEQ_AUDIT_LOGIN.NEXTVAL,x.OSUSER,x.USERNAME,x.MACHINE,x.PROGRAM);
				SELECT NVL(ID_LOGIN,0) INTO VID_LOGIN FROM AUDTUSER.AUDIT_LOGIN WHERE USERNAME=X.USERNAME AND OSUSER=X.OSUSER AND MACHINE=X.MACHINE AND PROGRAM=X.PROGRAM;
				INSERT INTO AUDTUSER.AUDIT_TIME VALUES (VID_LOGIN,TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
			ELSE
				SELECT NVL(ID_LOGIN,0) INTO VID_LOGIN FROM AUDTUSER.AUDIT_LOGIN WHERE USERNAME=X.USERNAME AND OSUSER=X.OSUSER AND MACHINE=X.MACHINE AND PROGRAM=X.PROGRAM;
				INSERT INTO AUDTUSER.AUDIT_TIME VALUES (VID_LOGIN,TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
			end if;

		end if;
	END LOOP;


COMMIT;

END;
/

SHOW ERR





select * from AUDTUSER.AUDIT_LOGIN;
select * from AUDTUSER.AUDIT_TIME;

alter TRIGGER TRG_LOGON_AUDUSER disable;
alter TRIGGER TRG_LOGON_AUDUSER enable;

truncate table AUDTUSER.AUDIT_TIME;
delete AUDTUSER.AUDIT_LOGIN CASCADE;
COMMIT;






#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer detalhes das sessões auditadas (logins)
#-- Nome do arquivo     : jbquery_audit.sql
#-- Data de criação     : 12/03/2015
#-- ---------------------------------------------------------------------------------------------------------#

set lines 200
set serveroutput on 

begin

for x in (
	select ID_LOGIN,OSUSER,USERNAME,MACHINE,PROGRAM from AUDTUSER.AUDIT_LOGIN order by USERNAME
)loop
	
	DBMS_OUTPUT.PUT_LINE(CHR(10));
	DBMS_OUTPUT.PUT_LINE('AUDITORIA DE CONEXOES'||CHR(10)||'===========================================');

	DBMS_OUTPUT.PUT_LINE('ORACLE USER:..................... ' || X.USERNAME || CHR(10));
	DBMS_OUTPUT.PUT_LINE('O/S USER:........................ ' || X.OSUSER);
	DBMS_OUTPUT.PUT_LINE('SERVIDOR:........................ ' || X.MACHINE || CHR(10));
	DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (PROGRAMA USADO):');
	DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:................. ' || X.PROGRAM || chr(10));

	DBMS_OUTPUT.PUT_LINE('HORARIO DAS CONEXOES:............ ' || chr(10));
	for y in (select LOGIN_TIME from AUDTUSER.AUDIT_TIME where ID_LOGIN=x.ID_LOGIN order by LOGIN_TIME )loop
		DBMS_OUTPUT.PUT_LINE(y.LOGIN_TIME);
	end loop;  

	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));

end loop;  

end;
/











set lines 200
set serveroutput on 

begin

for x in (
	select ID_LOGIN,OSUSER,USERNAME,MACHINE,PROGRAM from AUDTUSER.AUDIT_LOGIN order by USERNAME
)loop
	
	DBMS_OUTPUT.PUT_LINE(CHR(10));
	DBMS_OUTPUT.PUT_LINE('AUDITORIA DE CONEXOES'||CHR(10)||'===========================================');

	DBMS_OUTPUT.PUT_LINE('ORACLE USER:..................... ' || X.USERNAME || CHR(10));
	DBMS_OUTPUT.PUT_LINE('O/S USER:........................ ' || X.OSUSER);
	DBMS_OUTPUT.PUT_LINE('SERVIDOR:........................ ' || X.MACHINE || CHR(10));
	DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (PROGRAMA USADO):');
	DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:................. ' || X.PROGRAM || chr(10));

	DBMS_OUTPUT.PUT_LINE('HORARIO DAS CONEXOES:............ ' || chr(10));
	for y in (select LOGIN_TIME from AUDTUSER.AUDIT_TIME where ID_LOGIN=x.ID_LOGIN order by LOGIN_TIME )loop
		DBMS_OUTPUT.PUT_LINE(y.LOGIN_TIME);
	end loop;  

	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));

end loop;  

end;
/




