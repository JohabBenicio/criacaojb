#-- -----------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuario(s) e seu tamanho
#-- Nome do arquivo     : jbsizeowner.sql
#-- Data de criação     : 15/07/2014
#-- Data de atualização : 27/08/2014
#-- -----------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------#
#- TRAZER USUARIOS SELECIONADOS COM SEU TAMANHO ---------------------------------------------#
#--------------------------------------------------------------------------------------------#


set serveroutput on
set feedback off

declare
	v_schemas varchar2(300):=upper('&SCHEMAS');
	v_schemas2 varchar2(100);
	v_size varchar2(90);
	v_instance varchar2(90);
	v_dbsize varchar2(20):=0;
	v_virgula varchar2(20);
	v_query varchar2(1200);
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);


	v_owner varchar2(90);
	v_sum varchar2(90);

begin

	v_schemas:=upper(v_schemas)||',';

	dbms_output.put_line(JBQB||JBQB||JBQB);

	--dbms_output.put_line(v_schemas);

	dbms_output.put_line(JBQB||JBQB||JBQB);

	loop
		v_virgula := instr( v_schemas, ',' );
		exit when nvl(v_virgula, 0 ) = 0;
		v_schemas2 := rtrim( ltrim( substr( v_schemas, 1, v_virgula-1) ) );
		v_schemas  := substr( v_schemas, v_virgula+1 );

		dbms_output.put_line('========================================================================');

		begin

			SELECT OWNER, SUM(BYTES) into v_owner,v_sum FROM DBA_SEGMENTS where owner = v_schemas2 GROUP BY OWNER order by 2 desc;

			v_dbsize:=v_dbsize+v_sum;

			v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))-1);

			if v_size = '' or v_size is null then
				v_size:=v_sum /1024/1024/1024;
			end if;

			select instance_name into v_instance from v$instance;
			dbms_output.put_line('NOME DA INSTANCIA:......................... ' || upper(v_instance));
			dbms_output.put_line('NOME DO USUARIO:........... ' || v_owner);

			if v_size >= 1 then
				v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))+3);
				select replace(v_size,'.',',') into v_size from dual;
				dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' GB' || JBQB );

			else
				v_size:=substr(v_sum /1024/1024,1,(INSTR(v_sum /1024/1024,'.'))-1);

				if v_size = '' or v_size is null then
					v_size:=v_sum /1024/1024;
				end if;

				if v_size >= 1 then
					select replace(v_size,'.',',') into v_size from dual;
					dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' MB' || JBQB);

				else
					v_size:=substr(v_sum /1024,1,(INSTR(v_sum /1024,'.'))-1);

					if v_size = '' or v_size is null then
						v_size:=v_sum /1024;
					end if;

					if v_size >= 1 then
						dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' KB' || JBQB);
					else
						dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_sum || ' BYTES' || JBQB);
					end if;
				end if;
			end if;

		exception
		when others then

			begin

				select username into v_owner from dba_users where username = v_schemas2;

				if v_owner = v_schemas2 then
					dbms_output.put_line('NAO EXISTE DADOS PARA O SCHEMA:>>>>>>>>>>>>>>>> ' || v_schemas2 || JBQB);
				end if;

			exception
			when no_data_found then
				dbms_output.put_line('SCHEMA => ' || v_schemas2 || ' <= NAO EXISTE NESTE BANCO DE DADOS.' || JBQB);

			end;
		end;

	end loop;

	v_dbsize:=substr(v_dbsize /1024/1024/1024,1,(INSTR(v_dbsize /1024/1024/1024,'.'))+3);
	dbms_output.put_line(JBQB || 'TAMANHO TOTAL:.......... ' || v_dbsize || JBQB);

end;
/
