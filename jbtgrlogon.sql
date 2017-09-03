-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- -----------------------------------------------------------------------------------

CONNECT / AS SYSDBA

create user teor identified by "T30r@123";

grant connect, resource to teor;

DROP TABLE teor.user_login_audit;

create table teor.user_login_audit 
(
	horario_logon varchar2(20),
	usuario_banco varchar2(30),
	usuario_so varchar2(30),
	maquina_servidor varchar2(64),
	terminal varchar2(30),
	program varchar2(48)
);





CREATE OR REPLACE TRIGGER USER_LOGIN_TRIG AFTER LOGON ON DATABASE
begin
	insert into teor.user_login_audit
		select 
		to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss'),
		username, 
		osuser,
		machine,
		terminal,
		program
	from v$session
	where audsid = userenv('sessionid')
	and audsid != 0 
	and rownum = 1
	and username <> 'SYS'
	and (username <> 'UNKNOWN' or username <> '' or username is not null)
	and (terminal <> 'UNKNOWN' or terminal <> '' or terminal is not null); 

end;
/





-- QUERY COM HORARIO DA CONEXÃO

 
set serveroutput on
begin

	for x in (
		select 
			USUARIO_BANCO, USUARIO_SO, MAQUINA_SERVIDOR 
		from 
			teor.user_login_audit
		group by 
			USUARIO_BANCO, USUARIO_SO, MAQUINA_SERVIDOR)
	loop
		dbms_output.put_line('	');
		dbms_output.put_line('======================================================================');
		dbms_output.put_line('USUARIO CONECTADO NO BANCO DE DADOS:........ ' || x.USUARIO_BANCO);
		dbms_output.put_line('USUARIO CONECTADO NO SISTEMA OPERACIONAL:... ' || x.USUARIO_SO);
		dbms_output.put_line('MAQUINA DE ONDE ESTA CONECTADO:............. ' || x.MAQUINA_SERVIDOR);
		dbms_output.put_line('	');	
		dbms_output.put_line('PROGRAM:.................................... ');
	for pro in ( select PROGRAM from teor.user_login_audit where USUARIO_BANCO=x.USUARIO_BANCO group by PROGRAM ) loop
		dbms_output.put_line(pro.PROGRAM);
	end loop;
		dbms_output.put_line('	');	
		dbms_output.put_line('TERMINAL:................................... ');
	for ter in ( select TERMINAL from teor.user_login_audit where USUARIO_BANCO=x.USUARIO_BANCO group by TERMINAL ) loop
		dbms_output.put_line(ter.TERMINAL);
	end loop;
		dbms_output.put_line('	');
		dbms_output.put_line('HORARIO DA CONEXAO:......................... ');
	for y in ( select HORARIO_LOGON from teor.user_login_audit where USUARIO_BANCO=x.USUARIO_BANCO group by HORARIO_LOGON  ) loop
		dbms_output.put_line(y.HORARIO_LOGON);
	end loop;
	end loop;

end;
/



======================================================================
USUARIO CONECTADO NO BANCO DE DADOS:........ OWBREP
USUARIO CONECTADO NO SISTEMA OPERACIONAL:... oracle
MAQUINA DE ONDE ESTA CONECTADO:............. master

PROGRAM:....................................
sqlplus@master (TNS V1-V3)
JDBC Thin Client

TERMINAL:...................................
pts/2
unknown

HORARIO DA CONEXAO:.........................
01/07/2014 15:14:30
01/07/2014 15:12:31
01/07/2014 15:12:36



 
-- QUERY SEM HORARIO DA CONEXÃO
 

set serveroutput on
begin

	for x in (
		select 
			USUARIO_BANCO, USUARIO_SO, MAQUINA_SERVIDOR 
		from 
			teor.user_login_audit
		group by 
			USUARIO_BANCO, USUARIO_SO, MAQUINA_SERVIDOR)
	loop
		dbms_output.put_line('	');
		dbms_output.put_line('======================================================================');
		dbms_output.put_line('USUARIO CONECTADO NO BANCO DE DADOS:........ ' || x.USUARIO_BANCO);
		dbms_output.put_line('USUARIO CONECTADO NO SISTEMA OPERACIONAL:... ' || x.USUARIO_SO);
		dbms_output.put_line('MAQUINA DE ONDE ESTA CONECTADO:............. ' || x.MAQUINA_SERVIDOR);
		dbms_output.put_line('	');	
		dbms_output.put_line('PROGRAM:.................................... ');
	for pro in ( select PROGRAM from teor.user_login_audit where USUARIO_BANCO=x.USUARIO_BANCO group by PROGRAM ) loop
		dbms_output.put_line(pro.PROGRAM);
	end loop;
		dbms_output.put_line('	');	
		dbms_output.put_line('TERMINAL:................................... ');
	for ter in ( select TERMINAL from teor.user_login_audit where USUARIO_BANCO=x.USUARIO_BANCO group by TERMINAL ) loop
		dbms_output.put_line(ter.TERMINAL);
	end loop;

	end loop;

end;
/



======================================================================
USUARIO CONECTADO NO BANCO DE DADOS:........ OWBREP
USUARIO CONECTADO NO SISTEMA OPERACIONAL:... oracle
MAQUINA DE ONDE ESTA CONECTADO:............. master

PROGRAM:....................................
sqlplus@master (TNS V1-V3)
JDBC Thin Client

TERMINAL:...................................
pts/2
unknown





