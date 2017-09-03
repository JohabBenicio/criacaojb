#-- -----------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Limpar arquivos .trm .trc .aud
#-- Nome do arquivo     : jbrmdumps.sql
#-- Data de criação     : 01/07/2014
#-- Data de atualização :
#-- -----------------------------------------------------------------------------------------#

set serveroutput on
set pages 999
set lines 1000
set feedback off

declare

	qtd_dias numeric(3):=5;

begin

	dbms_output.put_line('	');dbms_output.put_line('	');dbms_output.put_line('	');

	for v1 in (select substr(VALUE,1,60) value from v$parameter where NAME like '%dump%' and VALUE not like '%udump%' and VALUE like '%/%') loop

		for v2 in 1..9 loop

			dbms_output.put_line( 'find ' || v1.value || ' -name *'|| v2 ||'.trc *'|| v2 ||'.trm -type f -mtime +'|| qtd_dias || ' -exec rm -f {} \;' ) ;

		end loop;

	end loop;

	for v1 in (select substr(VALUE,1,60) value from v$parameter where NAME like '%dump%' and VALUE like '%udump%' and VALUE like '%/%' ) loop

		for v2 in 1..9 loop

			dbms_output.put_line( 'find ' || v1.value || ' -name *'|| v2 ||'.trc -type f -mtime +'|| qtd_dias || ' -exec rm -f {} \;' ) ;

		end loop;

	end loop;

	for v1 in (select substr(VALUE,1,60) value from v$parameter where NAME like '%audit%' and VALUE like '%/%' ) loop

		for v2 in 1..9 loop

			dbms_output.put_line( 'find ' || v1.value || ' -name *'|| v2 ||'.aud -type f -mtime +'|| qtd_dias || ' -exec rm -f {} \;' ) ;

		end loop;

	end loop;
	dbms_output.put_line('	');dbms_output.put_line('	');dbms_output.put_line('	');
end;
/
