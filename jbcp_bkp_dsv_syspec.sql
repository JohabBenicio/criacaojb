-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Mantem uma retenção de 3 dias de backup.
-- Nome do arquivo     : jbcp_bkp_dsv_syspec.sql
-- Data de criação     : 16/04/2014
-- Data de atualização : 03/09/2014
-- -----------------------------------------------------------------------------------

set pages 500 
set lines 500
set long 500
set feedback off;
set serveroutput on

declare
	v_date varchar2(10);
	v_date_ctl varchar2(10);
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);
begin

for x in 4..15 loop
	
	select to_char(sysdate -x, 'dd_mm_yyyy') into v_date from dual;
	select to_char(sysdate -x, 'yyyymmdd') into v_date_ctl from dual;

	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\SYSPEC\FULL*' || v_date || '*');
	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\SYSPEC\CTL*' || v_date_ctl || '*');
	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\SYSPEC\ARCH*' || v_date || '*' || JBQB);

	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\DSV\FULL*' || v_date || '*');
	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\DSV\CTL*' || v_date_ctl || '*');
	dbms_output.put_line('del E:\BKP-FISICO-PRODUCAO\DSV\ARCH*' || v_date || '*' || JBQB);

end loop;

for y in 0..3 loop
	
	select to_char(sysdate -y, 'yyyymmdd') into v_date_ctl from dual;
	select to_char(sysdate -y, 'dd_mm_yyyy') into v_date from dual;

	dbms_output.put_line('xcopy C:\oracle\backup\SYSPEC\FULL*' || v_date || '*' || ' E:\BKP-FISICO-PRODUCAO\SYSPEC /D /C');
	dbms_output.put_line('xcopy C:\oracle\backup\SYSPEC\ARCH*' || v_date || '*' || ' E:\BKP-FISICO-PRODUCAO\SYSPEC /D /C');
	dbms_output.put_line('xcopy C:\oracle\backup\SYSPEC\CTL*' || v_date_ctl || '*' || ' E:\BKP-FISICO-PRODUCAO\SYSPEC /D /C' || JBQB);

	dbms_output.put_line('xcopy C:\oracle\backup\DSV\FULL*' || v_date || '*' || ' E:\BKP-FISICO-PRODUCAO\DSV /D /C');
	dbms_output.put_line('xcopy C:\oracle\backup\DSV\ARCH*' || v_date || '*' || ' E:\BKP-FISICO-PRODUCAO\DSV /D /C');
	dbms_output.put_line('xcopy C:\oracle\backup\DSV\CTL*' || v_date_ctl || '*' || ' E:\BKP-FISICO-PRODUCAO\DSV /D /C' || JBQB);
	
end loop;

	dbms_output.put_line('exit' || JBQB || JBQB || 'exit' || JBQB || JBQB);

end;
/

quit