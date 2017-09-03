-- ----------------------------------------------------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Analisa os datafiles candidatos a serem redimensionados e retorna o comandos com detalhes do datafile
-- Nome do arquivo     : jb_dealocate.sql
-- Data de criação     : 06/01/2016
-- Data de atualizacao : 18/04/2017
-- ----------------------------------------------------------------------------------------------------------------------------

set feedback on
set lines 200 pages 3000
set serveroutput on

declare
vblock number;
vnumerome varchar2(50);
vnumeroma varchar2(50);
vfile varchar2(90);
v_resize varchar2(2000);
begin
select value into vblock from v$parameter where name = 'db_block_size';
	dbms_output.put_line(chr(10)||chr(10));
	for x in (select a.file_id vx, a.file_name vy, ceil((nvl(hwm,1)*vblock)/1024) vz, ceil(blocks*vblock/1024) va, ceil(blocks*vblock/1024) - ceil((nvl(hwm,1)*vblock)/1024) vb,trunc(a.maxbytes/1024)  maxsize	from dba_data_files a, (select file_id, max(block_id+blocks-1) hwm
		from dba_extents group by file_id) b where a.file_id = b.file_id order by vb) loop
if x.vb > 500000 then
vnumerome:=x.vb - 100000;
vnumeroma:=x.vz + 100000;
vfile:=x.vx||','||vfile;
		dbms_output.put_line('FILE_ID:.............................. ' || x.vx );
		dbms_output.put_line('FILE_NAME:............................ ' || x.vy);
		dbms_output.put_line('TAMANHO ATUAL DO DATAFILE:............ ' || to_char(x.va,'99,999,999,999')  || ' resultado em Kb');
    if x.maxsize = 0 then
      dbms_output.put_line(chr(10)||'alter database datafile '||x.vx||' autoextend on next 128m maxsize '||x.va||'K;'||chr(10));
    else
      dbms_output.put_line('TAMANHO MAXIMO DO DATAFILE:........... ' || to_char(x.maxsize,'99,999,999,999')  || ' resultado em Kb');
      v_resize:=v_resize||chr(10)||'alter database datafile ' || x.vx || ' resize ' || vnumeroma || 'k;';
    end if;
		dbms_output.put_line('TAMANHO USADO:........................ ' || to_char(vnumeroma,'99,999,999,999') || ' resultado em Kb');
		dbms_output.put_line('ESPACO LIVRE DISPONIVEL:.............. ' || to_char(vnumerome,'99,999,999,999') || ' resultado em Kb');
		dbms_output.put_line(chr(10)||'alter database datafile ' || x.vx || ' resize ' || vnumeroma || 'k;');
		dbms_output.put_line(chr(10)||'___________________________________________________________________________________________' || chr(10));
		end if;
	end loop;
if vfile is not null then
    vfile:=substr(vfile,1,(length(vfile)-1));
-- dbms_output.put_line('define vtabcons='||vfile);
end if;

dbms_output.put_line(v_resize);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

end;
/
