export HOR=6
export VTMP=$(echo $HOR*60 | bc)
adrci exec="show home" | grep -v "Homes:" | while read homes
do
echo "set home $homes; purge -age $VTMP -type alert; purge -age $VTMP -type trace"
done



set home diag/asmcmd/user_oracle/atv-rac-01
purge -age 3 -type alert

set home diag/asmcmd/user_root/atv-rac-01
purge -age 3 -type alert

set home diag/tnslsnr/atv-rac-01/listener_scan3
purge -age 3 -type alert

set home diag/tnslsnr/atv-rac-01/listener_scan1
purge -age 3 -type alert

set home diag/tnslsnr/atv-rac-01/listener_scan2
purge -age 3 -type alert

set home diag/clients/user_root/host_1754794062_80
purge -age 3 -type alert
