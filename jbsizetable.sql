#--------------------------------------------------------------------------------------------#
#- TRAZER O TAMANHO DA TABELA ---------------------------------------------------------------#
#--------------------------------------------------------------------------------------------#
set serveroutput on
set feedback off

declare
	v_usu varchar2(90):='&&nume_usuario';
	v_tab varchar2(90):='&nume_tabela';
	v_1 varchar2(90);
	v_2 varchar2(90);
	v_3 varchar2(90);
	v_4 varchar2(90);
begin

	dbms_output.put_line('	');
	dbms_output.put_line('	');
	dbms_output.put_line('	');

	for x in (SELECT OWNER,SEGMENT_NAME, BYTES BYTES_SUM FROM DBA_SEGMENTS WHERE OWNER=upper(v_usu) and SEGMENT_NAME=upper(v_tab)) loop
		v_1:=x.owner;v_2:=x.BYTES_SUM /1024/1024/1024;v_3:=x.BYTES_SUM /1024/1024;v_4:=x.SEGMENT_NAME;
		dbms_output.put_line('NOME DO USUARIO:............ ' || v_1);
		if v_2 >= 1 then
		dbms_output.put_line('TAMANHO DA TABELA EM GB:.... ' || v_2 );
		dbms_output.put_line('TAMANHO DA TABELA EM MB:.... ' || v_3 );
		elsif v_3 >= 1 then
		dbms_output.put_line('TAMANHO DA TABELA EM MB:.... ' || v_3 );
		else
		dbms_output.put_line('TAMANHO DA TABELA EM BYTES:. ' || x.BYTES_SUM);
		end if;
		dbms_output.put_line('	');
	end loop;

end;
/




/*




v_tab varchar2(90):='&nume_tabela';


set serveroutput on
set feedback off

declare
	v_usu varchar2(300):='&USUARIO';
	v_tab varchar2(300):='&TABLE';

	v_sizeg varchar2(90);
	v_sizem varchar2(90);
	v_sizek varchar2(90);

	v_calc varchar2(90):=0;

	v_tab2 varchar2(100);
	v_size varchar2(90);
	v_instance varchar2(90);
	v_dbsize varchar2(20):=0;
	v_virgula varchar2(20);
	v_query varchar2(1200);
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);


	v_owner varchar2(90);
	v_sum varchar2(90);

	TYPE jbcorsor IS REF CURSOR;
	pidcursor jbcorsor;

begin

	v_tab:=upper(v_tab)||',';
	v_calc:=1073741824*1024;

	dbms_output.put_line(JBQB||JBQB||JBQB);

	dbms_output.put_line(v_tab);

	dbms_output.put_line(JBQB||JBQB||JBQB);

	loop
		v_virgula := instr( v_tab, ',' );
		exit when nvl(v_virgula, 0 ) = 0;
		v_tab2 := rtrim( ltrim( substr( v_tab, 1, v_virgula-1) ) );
		v_tab  := substr( v_tab, v_virgula+1 );

		dbms_output.put_line('========================================================================');

		begin

			SELECT OWNER,SEGMENT_NAME, SUM(BYTES) into v_owner,v_tab2,v_sum FROM DBA_SEGMENTS
			WHERE OWNER=upper(v_usu) and SEGMENT_NAME=v_tab2
			GROUP BY OWNER,SEGMENT_NAME order by 3 desc;

			--SELECT OWNER, SUM(BYTES) into v_owner,v_sum FROM DBA_SEGMENTS
			--where owner = v_tab2 GROUP BY OWNER order by 2 desc;

			v_dbsize:=v_dbsize+v_sum;

			v_sizeg:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))-1);

			if v_sizeg = '' or v_size is null then
				v_sizeg:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))+3);
				select replace(v_size,'.',',') into v_sizeg from dual;
			elsif v_size = '' or v_size is null then
				v_sizeg:=v_sum /1024/1024/1024;
			end if;


			select instance_name into v_instance from v$instance;
			dbms_output.put_line('NOME DA INSTANCIA:......................... ' || upper(v_instance));
			dbms_output.put_line('NOME DO USUARIO:........... ' || v_owner);


			if v_sum >= v_calc then
				dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_sizeg || ' GB' || JBQB );

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

				select username into v_owner from dba_users where username = v_tab2;

				if v_owner = v_tab2 then
					dbms_output.put_line('NAO EXISTE DADOS PARA O SCHEMA:>>>>>>>>>>>>>>>> ' || v_tab2 || JBQB);
				end if;

			exception
			when no_data_found then
				dbms_output.put_line('SCHEMA => ' || v_tab2 || ' <= NAO EXISTE NESTE BANCO DE DADOS.' || JBQB);

			end;
		end;

	end loop;

	v_dbsize:=substr(v_dbsize /1024/1024/1024,1,(INSTR(v_dbsize /1024/1024/1024,'.'))+3);
	dbms_output.put_line(JBQB || 'TAMANHO TOTAL:.......... ' || v_dbsize || JBQB);

end;
/

*/