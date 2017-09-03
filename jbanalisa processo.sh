
rm -f /tmp/teste.sh
vi /tmp/teste.sh
i
#!/bin/bash

export VPROC=ora_smon_jhbmst

while read vloop ;
do
VVALID=$(ps -ef | grep $VPROC | grep -v grep | wc -l)
if [ "$VVALID" -eq "0" ]; then
echo "Validado"
break
fi
sleep 3
done 

echo "continuando"

:wq!

