cat <<JHB>/tmp/jbdiff_param_inst.sh
clear
echo -e "\n"
ps -ef | grep smon | grep -iv "grep\|+asm\|/\|-" | sed 's/.*mon_\(.*\)\$/\1/'
echo -e "\n"
read -p "Informe o nome da primeira instancia: " SID1
read -p "Informe o nome da primeira instancia: " SID2
clear
echo -e "\n\n"
alias sid1="export ORAENV_ASK=NO ; ORACLE_SID=\$SID1 ; . oraenv; export ORAENV_ASK=YES"
alias sid2="export ORAENV_ASK=NO ; ORACLE_SID=\$SID2 ; . oraenv; export ORAENV_ASK=YES"
echo -e "\n\n\n"

function analisa_parameter(){
sqlplus -S / as sysdba <<EOF>/tmp/JBparameter\$ORACLE_SID.log
col text for a100
set lines 200 pages 2000
select INST_ID,NAME||': '||VALUE text from gv\\\$parameter where value not like '%/%' order by 1,2;
quit;
EOF
}

sid1
analisa_parameter
sid2
analisa_parameter

diff -y /tmp/parameter\$SID1.log /tmp/parameter\$SID2.log > /tmp/JBdiffer_parameters.log
cat /tmp/differ_parameters.log | grep "|" | grep -v "rows selected"
echo -e "\n\n\n"

if [ -e "/tmp/JBparameter\$SID1.log" ]; then
rm -f /tmp/parameter\$SID1.log
fi

if [ -e "JBparameter\$SID2.log" ]; then
rm -f /tmp/JBparameter\$SID2.log
fi

if [ -e "/tmp/JBdiffer_parameters.log" ]; then
rm -f /tmp/JBdiffer_parameters.log
fi



JHB
