

rm -f /tmp/jbblock_corruption.sh

vi /tmp/jbblock_corruption.sh
i
#!/bin/bash
#-- ----------------------------------------------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Consulta alertas de blocos corrompidos no alert.log do banco de dados e traz detalhes do mesmo.
#-- Nome do arquivo     : jbblock_corrupt.sql
#-- Data de criação     : 24/11/2014
#-- Data de atualização : 23/08/2015
#-- ----------------------------------------------------------------------------------------------------------------------

JBSCRIPT=/tmp/jbblock_corrupt.sql
rm -f $JBSCRIPT

echo -e "\nInstancias deste server."
ps -ef | grep smon | grep -v -i "asm\|grep\|opuser" | sed 's/.*smon_//' | grep -v "/"
echo -e "\n"
read -p "Informe o nome de uma instancia: " INSTANCE

read -p "Voce quer que eu encontre o alet.log desta instancia para voce? (1) sim ou (2) não: " ALERT_SN

if [ "$ALERT_SN" = "1" ]; then
find $ORACLE_BASE/ -name "alert_$INSTANCE\.log" 2>&-
echo -e "\n"
fi

read -p "Informe o nome do alert.log a ser analisado: " ALERT

MOTH=$(date +"%m")

if [ "$MOTH" -eq "1" ]; then
DAT="Jan"
elif [ "$MOTH" -eq "2" ]; then 
DAT="Feb"
elif [ "$MOTH" -eq "3" ]; then 
DAT="Mar"
elif [ "$MOTH" -eq "4" ]; then 
DAT="Apr"
elif [ "$MOTH" -eq "5" ]; then 
DAT="May"
elif [ "$MOTH" -eq "6" ]; then 
DAT="Jun"
elif [ "$MOTH" -eq "7" ]; then 
DAT="Jul"
elif [ "$MOTH" -eq "8" ]; then 
DAT="Aug"
elif [ "$MOTH" -eq "9" ]; then 
DAT="Sep"
elif [ "$MOTH" -eq "10" ]; then 
DAT="Oct"
elif [ "$MOTH" -eq "11" ]; then 
DAT="Nov"
elif [ "$MOTH" -eq "12" ]; then 
DAT="Dec"
fi


cat <<EOF>$JBSCRIPT
set serveroutput on
set lines 200
set feedback off
set pages 200

declare
	vowner varchar2(90);
	vtype varchar2(90);
	vname varchar2(90);
	vfile varchar2(20);
	vblock varchar2(20);
	vtipoalert varchar2(20);
	vsize varchar2(20);
BEGIN

dbms_output.put_line('#-- ----------------------------------------------------------------------------------------------------------------------');
dbms_output.put_line('#-- Autor               : Johab Benicio de Oliveira.');
dbms_output.put_line('#-- Descricao           : Consulta alertas de blocos corrompidos no alert.log do banco de dados e traz detalhes do mesmo.');
dbms_output.put_line('#-- Nome do arquivo     : jbblock_corrupt.sql');
dbms_output.put_line('#-- Data de criacao     : 24/11/2014');
dbms_output.put_line('#-- Data de atualizacao : 23/08/2015');
dbms_output.put_line('#-- ----------------------------------------------------------------------------------------------------------------------'||chr(10)||chr(10)||chr(10));

EOF

DATGREP=$(cat $ALERT | grep "$DAT [0-31]\(.*\)$(date +"%Y")" | head -1)
VALID=$(cat $ALERT | grep -A 999999 "$DATGREP" | grep "file\(.*\)\+block" | sort | uniq |  sed 's/\(.*\)file//g' | grep -E "(|^ )block( |$)" | sed 's/block//g' | sed 's/)\(.*\)//g' | sed 's/#//g' | sed 's/(//g' | sed 's/,/;/g' | sed 's/ /;/g' | sed 's/;;/;/g'|sed 's/;;/;/g'|sed 's/;;/;/g' | awk '{print $1";"}'|sed 's/;;/;/g' | sort | uniq | wc -l)

if [ "$VALID" -eq "0" ]; then
cat <<EOF>>$JBSCRIPT
	dbms_output.put_line('NAO ENCONTRADO NENHUM BLOCO CORROMPIDO NO ALERT.LOG A PARTIR DE --->>> $DATGREP '||chr(10)||chr(10)||chr(10)||chr(10));
exception
  when others then
    null;
end;
/
EOF

else

cat $ALERT | grep -A 999999 "$DATGREP" | grep "file\(.*\)\+block" | sort | uniq |  sed 's/\(.*\)file//g' | grep -E "(|^ )block( |$)" | sed 's/block//g' | sed 's/)\(.*\)//g' | sed 's/#//g' | sed 's/(//g' | sed 's/,/;/g' | sed 's/ /;/g' | sed 's/;;/;/g'|sed 's/;;/;/g'|sed 's/;;/;/g' | awk '{print $1";"}'|sed 's/;;/;/g' | sort | uniq | while read corrupt
do
cat <<EOF>>$JBSCRIPT
	vfile:=$(echo $corrupt | cut -d ";" -f 2);
	vblock:=$(echo $corrupt | cut -d ";" -f 3);

	select segment_type,owner,segment_name into vtype,vowner,vname from dba_extents where file_id = vfile and vblock between block_id and block_id+blocks -1;
	select bytes/1024/1024 into vsize from dba_extents where owner=vowner and segment_name=vname;
	dbms_output.put_line('DADOS DO BLOCO CORROMPIDO:');
	dbms_output.put_line('FILE ID:...................... '||vfile);
	dbms_output.put_line('BLOCK:........................ '||vblock);
	dbms_output.put_line('DONO DO OBJETO:............... '||vowner);
	dbms_output.put_line('NOME DO OBJETO:............... '||vname);
	dbms_output.put_line('TIPO DO OBJETO:............... '||vtype);
	dbms_output.put_line('TAMANHO DO OBJETO:............ '||vsize||' MB');

	if vtype = 'INDEX' then
		dbms_output.put_line(chr(10)||'ACOES A SER EXECUTADAS');
		dbms_output.put_line('PRIMEIRO TENTE REBUILD:.................. ALTER INDEX '||vowner||'.'||vname||' REBUILD ONLINE;'||chr(10));
		dbms_output.put_line('CASO O PRIMEIRO FALHE, TENTE RECRIAR:'||chr(10)||'set long 999;'||chr(10)||'set lines 200;'||chr(10)||'select dbms_metadata.get_ddl(''INDEX'','''||vname||''','''||vowner||''') from dual;');
	end if;
	
	dbms_output.put_line(chr(10)||'======================================================================================================================='||chr(10)||chr(10));

EOF

done

cat <<EOF>> $JBSCRIPT

exception
  when others then
    null;
end;
/
EOF

fi

clear

echo -e "\n\n Execute o script: $JBSCRIPT na instancia \"$INSTANCE\"\nexport ORACLE_SID=$INSTANCE\nsqlplus / as sysdba\n\n"




:wq!







chmod 755 /tmp/jbblock_corruption.sh


