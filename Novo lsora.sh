ls $ODS_HOME/config/ | grep -vi default.conf |  awk -F. '{print $1}' >/tmp/LSINS.out
cat -n /tmp/LSINS.out


while read -r INST;
do
$(ls $ODS_HOME/config/ | wl -l)


done < "/tmp/LSINS.out"


cat $ODS_HOME/config/$arqfile | grep -i job_type | while read vjob
do
JOB=$(echo $vjob | cut -d "." -f 1 )
cat <<EOF
#######################################################################
# DRYRUN do job de backup $DB.$JOB
#######################################################################

EOF
$ODS_HOME/bin/orabkp backup -d $DB -j $JOB -dryrun
done
done
cat <<EOF