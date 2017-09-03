#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira, Luiz Fernando e Fabio Galao.
#-- Descrição           : Trazer os objetos proximos a marca d'agua.
#-- Nome do arquivo     : jbls_objs_HWM.sql
#-- Data de criação     : 19/01/2016
#-- ---------------------------------------------------------------------------------------------------------#


define vtabcons=HDM_TS
define return=40


set pages 2000 lines 200
col segment_name for a30
select to_char(round(sum(bytes)/1024/1024,0),'999g999g999') "Segment Size (MB)" from dba_segments where tablespace_name='&&vtabcons';

select a.file_id,to_char(round(a.bytes/1024/1024,0),'999g999g999') TAMANHO from dba_data_files a, v$datafile b, dba_tablespaces t  where a.file_id = b.file# and t.tablespace_name = a.tablespace_name and t.tablespace_name = upper('&&vtabcons') order by 2;

select file_id, owner,segment_name, segment_type, round(TOTAL_MB-ULTIMO_EXTENT_MB,0) LIBERA_MB,to_char(round(SIZE_OBJ,0),'999g999g999') SIZE_OBJ,to_char(round(TOTAL_MB,0),'999g999g999') DATAFILE_SIZE from
    ( select  e.file_id, e.tablespace_name, e.segment_type, e.owner, e.segment_name, (max(d.bytes/1024/1024))TOTAL_MB, ((max(e.block_id+e.blocks-1)*8192)/1024/1024) ULTIMO_EXTENT_MB, e.bytes/1024/1024 SIZE_OBJ from dba_extents e, dba_data_files d where e.file_id=d.file_id
        and e.file_id=&file_id
        group by e.file_id, e.tablespace_name, e.segment_type, e.segment_name,e.owner,e.bytes
        order by 7 desc
    )
where rownum<=&&return;
