set lines 200 pages 999
set serveroutput on size unlimited
declare
    vowner_name varchar2(90):='MKSAUDE';
    vqtd_nextval varchar2(300):=1000;
    current_val varchar2(300);
    primeiro_val varchar2(300);
    next_sequence varchar2(300);
BEGIN

for x in (select SEQUENCE_OWNER,SEQUENCE_NAME from dba_sequences where SEQUENCE_OWNER=vowner_name)LOOP

next_sequence:=x.SEQUENCE_OWNER||'.'||x.SEQUENCE_NAME||'.NEXTVAL';

    for qtd in 1..vqtd_nextval LOOP
        if primeiro_val is null then
            execute immediate 'select '||next_sequence||' from dual' into current_val;
            primeiro_val:=current_val-1;
        else
            execute immediate 'select '||next_sequence||' from dual' into current_val;
        end if;
    END LOOP;
    dbms_output.put_line('Sequencia '||chr(34)||x.SEQUENCE_OWNER||'.'||x.SEQUENCE_NAME||chr(34)||' atualizado com sucesso. Atualizado '||primeiro_val||' para '||current_val||'.');
    primeiro_val:=null;
END LOOP;

END;
/

