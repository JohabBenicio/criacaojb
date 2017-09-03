
cat <<EOF>/tmp/jbchown_files.sh
#!/bin/bash

if [ -z "\$1" ]; then
echo -e "\n\nDigite: \$0 <DIRETORIO> \n\n"
exit;
fi
PART=\$1
find \$PART/ -exec ls -l {} \; | grep "\$PART/" | while read FILE
do
PERM=\$(echo \$FILE | awk '{print \$1}')
USER=\$(echo \$FILE | awk '{print \$3}')
GROUP=\$(echo \$FILE | awk '{print \$4}')
FILE=\$(echo \$FILE | awk '{print \$NF}')

if [ "\$(echo \$PERM | grep d | wc -l)" -eq "0" ]; then
echo "chown \$USER:\$GROUP \$FILE"
fi
done
EOF

chmod +x /tmp/jbchown_files.sh

