
set lines 200 pages 9999
set serveroutput on
declare
    v_table     varchar2(100):='&NOME_TABELA';
    v_return    number:=&RETORNAR_N_LINHAS;
    v_datafileT varchar2(400); -- Titulo
    v_datafileL varchar2(400); -- Linhas
    v_obj_name  varchar2(200);

BEGIN

v_datafileT:=rpad('FILE ID',7,' ')||chr(32)||rpad('OWNER',18,' ')||chr(32)||rpad('SEGMENT NAME',50,' ')||chr(32)||rpad('SEGMENT TYPE',15,' ')||chr(32)||rpad('LIBERAR (MB)',12,' ')||chr(32)||rpad('SIZE OBJ. (MB)',15,' ')||chr(32)||rpad('SIZE DATAFILE ATUAL (MB)',25,' ');

v_datafileL:='-------'            ||chr(32)||rpad('-',18,'-')    ||chr(32)||rpad('-',50,'-')           ||chr(32)||rpad('-',15,'-')           ||chr(32)||rpad('-',12,'-')           ||chr(32)||rpad('-',15,'-')             ||chr(32)||rpad('-',25,'-');

for x in
(
    select distinct file_id
    from dba_extents
    where segment_name = v_table
    order by file_id
) LOOP

dbms_output.put_line(chr(10)||chr(10)||'############### DATAFILE '||x.file_id||' ###############'||chr(10));
dbms_output.put_line(v_datafileT);
dbms_output.put_line(v_datafileL);

    for y in
    (
        select file_id,
            owner,
            segment_name,
            segment_type,
            round(TOTAL_MB-ULTIMO_EXTENT_MB,0) LIBERA_MB,
            ltrim(rtrim(to_char(round(SIZE_OBJ,0),'999g999g999'))) SIZE_OBJ,
            ltrim(rtrim(to_char(round(TOTAL_MB,0),'999g999g999'))) DATAFILE_SIZE
        from
        (
            select e.file_id,
                e.tablespace_name,
                e.segment_type,
                e.owner,
                e.segment_name,
                (max(d.bytes/1024/1024))TOTAL_MB,
                ((max(e.block_id+e.blocks-1)*8192)/1024/1024) ULTIMO_EXTENT_MB,
                e.bytes/1024/1024 SIZE_OBJ
            from dba_extents e, dba_data_files d
            where   e.file_id=d.file_id
                and e.file_id=x.FILE_ID
            group by e.file_id, e.tablespace_name, e.segment_type, e.segment_name,e.owner,e.bytes
            order by 7 desc
        )
        where rownum<=v_return
    ) LOOP

        if y.segment_type = 'LOBSEGMENT' then
            select table_name||'('||segment_name||')' into v_obj_name from dba_lobs where owner=y.owner and segment_name=y.segment_name;
        else
            v_obj_name:=y.segment_name;
        end if;

            dbms_output.put_line(rpad(y.file_id,7,' ')||chr(32)||rpad(y.owner,18,' ')||chr(32)||rpad(v_obj_name,50,' ')||chr(32)||rpad(y.segment_type,15,' ')||chr(32)||rpad(y.libera_mb,12,' ')||chr(32)||rpad(y.size_obj,15,' ')||chr(32)||rpad(y.datafile_size,25,' '));


    END LOOP;
END LOOP;
END;
/
