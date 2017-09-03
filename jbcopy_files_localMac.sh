#!/bin/bash

IP=10.1.2.148

function copy_files (){
sshpass -p Or@0R3Le2014 ssh oracle@$IP ls -lthr /tmp/audit*.txt
echo -e "\n"
read -p "Informe o nome do arquivo: " FILE
if [ -z $FILE ]; then
copy_files
fi
sshpass -p Or@0R3Le2014 scp oracle@$IP:/tmp/$FILE /Users/johab/Documents/trabalho/tegma
copy_files
}
copy_files
