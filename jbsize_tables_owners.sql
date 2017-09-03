#--------------------------------------------------------------------------------------------#
#- TRAZER O TAMANHO DA TABELA ---------------------------------------------------------------#
#--------------------------------------------------------------------------------------------#
set serveroutput on
set feedback off

declare
    v_usu varchar2(90):='&nume_usuario';
    v_1 varchar2(90);
    v_2 varchar2(90);
    v_3 varchar2(90);
    v_4 varchar2(90);
begin

    dbms_output.put_line('  ');
    dbms_output.put_line('  ');
    dbms_output.put_line('  ');

    for x in (SELECT OWNER,SEGMENT_NAME, BYTES BYTES_SUM FROM DBA_SEGMENTS WHERE OWNER=upper(v_usu)) loop
        v_1:=x.owner;v_2:=x.BYTES_SUM /1024/1024/1024;v_3:=x.BYTES_SUM /1024/1024;v_4:=x.SEGMENT_NAME;
        dbms_output.put_line('NOME DDA ATABELA:........... ' || x.SEGMENT_NAME);
        if v_2 >= 1 then
        dbms_output.put_line('TAMANHO DA TABELA EM GB:.... ' || v_2 );
        dbms_output.put_line('TAMANHO DA TABELA EM MB:.... ' || v_3 );
        elsif v_3 >= 1 then
        dbms_output.put_line('TAMANHO DA TABELA EM MB:.... ' || v_3 );
        else
        dbms_output.put_line('TAMANHO DA TABELA EM BYTES:. ' || x.BYTES_SUM);
        end if;
        dbms_output.put_line('  ');
    end loop;

end;
/
