#-- -----------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer tablespace(s) e usuario(s) que estao usando o mesmo.
#-- Nome do arquivo     : jbtbs_owner.sql
#-- Data de criação     : 04/09/2014
#-- -----------------------------------------------------------------------------------------#


set serveroutput on
set feedback off
set lines 200
set pages 200

declare 
	v_tablespaces varchar2(300):='&TABLESPACES';
	v_tablespaces2 varchar2(100);
	v_virgula varchar2(20);

	v_instance varchar2(90);
	v_query varchar2(1200);
	
	v_owner varchar2(90);
	v_sum varchar2(90);

	v_tbs_size varchar2(30);
	v_tbsg_tbsm char(6);

	v_valid varchar2(60);
	v_size_total varchar2(200):=0;

	jbqb VARCHAR2(2) := CHR(13) || CHR(10);

begin
	
	v_tablespaces:=upper(v_tablespaces)||',';
	--dbms_output.put_line(jbqb||jbqb||jbqb||v_tablespaces||jbqb||jbqb);
	dbms_output.put_line(jbqb||jbqb||jbqb||jbqb||jbqb);

	loop
		v_virgula := instr( v_tablespaces, ',' );
		exit when nvl(v_virgula, 0 ) = 0;
		v_tablespaces2 := rtrim( ltrim( substr( v_tablespaces, 1, v_virgula-1) ) );
		v_tablespaces  := substr( v_tablespaces, v_virgula+1 );

		begin

			select distinct tablespace_name into v_valid from dba_segments 
			where tablespace_name=v_tablespaces2;

			dbms_output.put_line(jbqb||'.. .......................................................................................');
			dbms_output.put_line('.. TABLESPACE NAME:.................. ' || v_valid );
			dbms_output.put_line('.. .......................................................................................' || jbqb);			

			for x in (select owner,sum(bytes) tbs_sum
				from dba_segments 
				group by owner,tablespace_name having tablespace_name=v_tablespaces2
			)loop

				v_owner := x.owner;
				v_sum := x.tbs_sum;
				v_size_total := v_sum+v_size_total;

  				v_tbs_size := substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))+3);
  				v_tbsg_tbsm := ' GB';
				
				if v_tbs_size is null or v_tbs_size < 1 then
          			v_tbs_size := v_sum /1024/1024/1024;
          			v_tbsg_tbsm := ' GB';
          			
          			if v_tbs_size is null or v_tbs_size < 1 then
            			v_tbs_size := substr(v_sum /1024/1024,1,(INSTR(v_sum /1024/1024,'.'))-1);
            			v_tbsg_tbsm := ' MB';
            			
            			if v_tbs_size is null or v_tbs_size < 1 then
              				v_tbs_size := v_sum /1024/1024;
              				v_tbsg_tbsm := ' MB';
  				    		
  				    		if v_tbs_size is null or v_tbs_size < 1 then
  				    			v_tbs_size := substr(v_sum /1024,1,(INSTR(v_sum /1024,'.'))-1);
  				    			v_tbsg_tbsm := ' KB';
                				
                				if v_tbs_size is null or v_tbs_size < 1 then
                  					v_tbs_size := v_sum /1024;
                  					v_tbsg_tbsm := ' KB';
                  					
                  					if v_tbs_size is null or v_tbs_size < 1 then
                    					v_tbs_size := v_sum;
                    					v_tbsg_tbsm := ' BYTES';
                    				end if;
                  				end if;
                			end if;
              			end if;
            		end if;
          		end if;

  				dbms_output.put_line('OWNER NAME:........... ' || v_owner );
  				dbms_output.put_line('SIZE USED:............ ' || v_tbs_size || v_tbsg_tbsm || jbqb);

			end loop;
			
		exception
		when no_data_found then

			for y in (select distinct tablespace_name from dba_tablespaces where contents='TEMPORARY'
			)loop
				if y.tablespace_name = v_tablespaces2 then
					dbms_output.put_line('++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
					dbms_output.put_line('++ Tablespace => ' || v_tablespaces2 || ' <= e uma tablespace temporaria.');				
					dbms_output.put_line('++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' || jbqb);			
				else

					BEGIN
					  	select distinct tablespace_name into v_valid from dba_tablespaces 
						where tablespace_name=v_tablespaces2;

						dbms_output.put_line('|| |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');	
						dbms_output.put_line('|| Nenhum owner esta usando a tablespace => ' || v_valid );				
						dbms_output.put_line('|| |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||' || jbqb);	
					
					EXCEPTION
					  WHEN no_data_found THEN
						dbms_output.put_line('-- ---------------------------------------------------------------------------------------');
						dbms_output.put_line('-- Tablespace => ' || v_tablespaces2 || ' <= nao existe neste banco de dados.');				
						dbms_output.put_line('-- ---------------------------------------------------------------------------------------' || jbqb);			

					END;
					
				end if;

			end loop;

		end;
	end loop;

	v_tbs_size:=v_size_total;
	v_size_total := substr(v_tbs_size /1024/1024/1024,1,(INSTR(v_tbs_size /1024/1024/1024,'.'))+3);
	v_tbsg_tbsm := ' GB';
	if v_size_total is null or v_size_total < 1 then
		v_size_total := v_tbs_size /1024/1024/1024;
		v_tbsg_tbsm := ' GB';
		if v_size_total < 1 then
			v_size_total := substr(v_tbs_size /1024/1024,1,(INSTR(v_tbs_size /1024/1024,'.'))-1);
			v_tbsg_tbsm := ' MB';
			if v_size_total is null then
				v_size_total := v_tbs_size /1024/1024;
				v_tbsg_tbsm := ' MB';
			end if;
		end if;
	end if;
	dbms_output.put_line('== =======================================================================================');
	dbms_output.put_line('== SOMA DO ESPACO USADO DAS TABLESPACES:.......... ' || v_size_total || v_tbsg_tbsm);
	dbms_output.put_line('== =======================================================================================');
	dbms_output.put_line(jbqb||jbqb||jbqb||jbqb||jbqb);


end;
/
