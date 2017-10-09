
set serveroutput on
declare
    vowner_name varchar2(90):='MKSAUDE';
    vqtd_nextval varchar2(300):=2000;
    current_val varchar2(300);
    primeiro_val varchar2(300);
    curr_sequence varchar2(300);
    next_sequence varchar2(300);
BEGIN

for x in (select SEQUENCE_OWNER,SEQUENCE_NAME from dba_sequences where SEQUENCE_OWNER=vowner_name)LOOP

next_sequence:=x.SEQUENCE_OWNER||'.'||x.SEQUENCE_NAME||'.NEXTVAL';
curr_sequence:=x.SEQUENCE_OWNER||'.'||x.SEQUENCE_NAME||'.CURRVAL';

    for qtd in 1..vqtd_nextval LOOP
        if primeiro_val is null then
            execute immediate 'select '||curr_sequence||' from dual' into primeiro_val;
            execute immediate 'select '||next_sequence||' from dual' into current_val;
        else
            execute immediate 'select '||next_sequence||' from dual' into current_val;
        end if;
    END LOOP;
    dbms_output.put_line('Sequencia '||chr(34)||x.SEQUENCE_OWNER||'.'||x.SEQUENCE_NAME||chr(34)||' atualizado com sucesso. Atualizado '||primeiro_val||' para '||current_val||'.');
    primeiro_val:=null;
END LOOP;

END;
/

