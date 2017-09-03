#!/bin/bash

cat <<EOF
#################################################################
# Informe o nome da instancia.
#
#################################################################
EOF

while read -r instancia
do
echo $instancia
done< "$(ps -ef | grep smon )"
