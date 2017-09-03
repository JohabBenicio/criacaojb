




FILE=impdp*.log
cat $FILE | grep "ORA-01917: user or role" | cut -d "'" -f 2 | sort | uniq

cat $FILE | grep "ORA-01918: user " | cut -d "'" -f 2 | sort | uniq




FILE=impdp*.log
FILE_SQL=/tmp/synonym.sql
rm -f $FILE_SQL
cat <<EOF>$FILE_SQL
set serveroutput on;
set sqlblanklines on;
set timing on;
set echo on
EOF
cat $FILE | grep -i "SYNONYM " | grep -v "/\|ORA-" | while read grant
do
echo "$grant;">>$FILE_SQL
done



FILE=impdp*.log
FILE_SQL=/tmp/contraints.sql
rm -f $FILE_SQL
cat <<EOF>$FILE_SQL
set serveroutput on;
set sqlblanklines on;
set timing on;
set echo on
EOF
cat $FILE | grep "ADD CONSTRAINT" | grep -v "ORA-" | sed 's/) ENABLE/) ENABLE NOVALIDATE;/g' >> $FILE_SQL


FILE=impdp*.log
FILE_SQL=/tmp/grants.sql
rm -f $FILE_SQL
cat <<EOF>$FILE_SQL
set serveroutput on;
set sqlblanklines on;
set timing on;
set echo on
EOF
cat $FILE | grep "GRANT " | grep -v "/\|ORA-" | while read grant
do
echo "$grant;">>$FILE_SQL
done




