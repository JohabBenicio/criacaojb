
WLSCRIPT_HOME="/tmp"

cat <<JBEOF> $WLSCRIPT_HOME/jbStartServicesWebLog.sh

#!/bin/bash
. /home/oracle/.bash_profile

export VSERV="wl_server_01,weblogic.com;wl_server_02,weblogic.com;wl_server_03,serverapp4.localdomain;wl_server_04,serverapp4.localdomain"
export WLST="/u01/oracle/middleware/Oracle_Home/wlserver/common/bin/wlst.sh"
export VTEMPSTARMIN=3
export VUSER="weblogic"
export VPASS="welcome1"
export VURL="t3://weblogic.com:7001"
export VMP="5556"
export VDOMAIN="wl_domain"
export DOMAIN_HOME="/u01/oracle/domains/wl_domain"
export DIR_LOG="/tmp"
export ADMINSERVER="AdminServer"
export SERVERSEXTER="serverapp4.localdomain"
export WLSCRIPT_HOME="/tmp"


if [ -z \$1 ]; then
OPT="NONE"
else
OPT=\$1
fi;
OPTION=\$(echo "\$1" | tr [a-z] [A-Z])


case \$OPTION in
   ALL)
   sh $WLSCRIPT_HOME/StartupNodeManager.sh
   sh $WLSCRIPT_HOME/StartupAdminServer.sh
   sh $WLSCRIPT_HOME/StartupServerManager.sh
   ;;
   MANAGERSERV) sh $WLSCRIPT_HOME/StartupServerManager.sh ;;
   NODEMANAGER) sh $WLSCRIPT_HOME/StartupNodeManager.sh ;;
   ADMINSERVER) sh $WLSCRIPT_HOME/StartupAdminServer.sh ;;
   *)
cat <<EOF
Digite: $WLSCRIPT_HOME/jbStartServicesWebLog.sh OPTION

OPTION:
        "ALL"        : Sobe o Node Manager, Admin Server e os Managers Servers.
        "NODEMANAGER": Sobe o Node Manager.
        "ADMINSERVER": Sobe o Admin Server.
        "MANAGERSERV": Sobe os Managers Servers.
EOF
exit;
   ;;
esac

JBEOF









cat <<JBEOF> $WLSCRIPT_HOME/StartupNodeManager.sh
#!/bin/bash
## #############################################################
#   Startup Node Managers
## #############################################################

export VCOUNTADDE=\$(echo \$SERVERSEXTER | sed 's/;/\n/g' | wc -l)

if [ \$VCOUNTADDE -eq 0 ]; then
export VZERO=1;
fi;


for ((N=1;N<=\$VCOUNTADDE;N++));
do

if [ -z \$VZERO ]; then
wl_servers=\$(echo \$SERVERSEXTER | cut -f \$N -d ';')
else
wl_servers=\$SERVERSEXTER
fi

if [ ! -z \$SERVERSEXTER ]; then
STARTNODEEXTERN=\$(ssh \$SERVERSEXTER locate startNodeManager.sh | grep wlserver | grep -vi "template")
nohup ssh \$SERVERSEXTER \$STARTNODEEXTERN >/tmp/startNodeManager.log &
fi;

STARTNODELOCAL=\$(locate startNodeManager.sh | grep wlserver | grep -vi "template")

nohup \$STARTNODELOCAL >\$DIR_LOG/startNodeManager.log &


done



JBEOF



cat <<JBEOF> $WLSCRIPT_HOME/StartupAdminServer.sh
#!/bin/bash
## #############################################################
#   Startup Node AdminServer
## #############################################################

function StatusAdminServer {
\$WLST <<EOF
connect('\$VUSER','\$VPASS','\$VURL');
state('\$VSM')
exit();
EOF
}

VALID=\$(echo \$(StatusAdminServer) | grep 'RUNNING' | wc -l)

if [ "\$VALID" -eq "0" ]; then

\$WLST <<EOF
startServer('\$ADMINSERVER','\$VDOMAIN','\$VURL','\$VUSER','\$VPASS','\$DOMAIN_HOME','true',1200000,'false');
exit();
EOF

fi;


JBEOF








cat <<JBEOF> $WLSCRIPT_HOME/StartupServerManager.sh
#!/bin/bash
## #############################################################
#   Startup Servers managers
## #############################################################
export VCOUNTSERV=\$(echo \$VSERV | sed 's/;/\n/g' | wc -l)

while true
do
VALID=\$(ps -ef | grep -i "weblogic.NodeManager" | grep -v "grep\|weblogic.Server" | wc -l)
if [ \$VALID -gt 0 ]; then

if [ \$VCOUNTSERV -eq 0 ]; then
export VZERO=1;
fi;

for ((N=1;N<=\$VCOUNTSERV;N++));
do

if [ -z \$VZERO ]; then
wl_servers=\$(echo \$VSERV | cut -f \$N -d ';')
else
wl_servers=\$VSERV
fi

VSM=\$(echo \$wl_servers | cut -f 1 -d ',')
VM=\$(echo \$wl_servers | cut -f 2 -d ',')

function StartServerManager {
\$WLST <<EOF>> \$DIR_LOG/startupServer\$VSM.log
nmConnect('\$VUSER','\$VPASS','\$VM','\$VMP','\$VDOMAIN','\$DOMAIN_HOME','SSL');
nmStart('\$VSM');
exit();
EOF
}

function ResumeServerManager {
\$WLST <<EOF
connect('\$VUSER','\$VPASS','\$VURL');
resume('\$VSM');
exit();
EOF
}

function StatusServerManager {
\$WLST <<EOF
connect('\$VUSER','\$VPASS','\$VURL');
state('\$VSM')
exit();
EOF
}

VALID=\$(echo \$(StatusServerManager) | grep 'RUNNING' | wc -l)


if [ "\$VALID" -eq "0" ]; then
StartServerManager &
sleep 2

while true
do
VEXIT=\$(echo \$(StatusServerManager) | grep 'RUNNING' | wc -l)
if [ "\$VEXIT" -gt "0" ]; then
break
else
VEXECRESUME=\$(find \$DIR_LOG/startupServer\$VSM.log -mmin +\$VTEMPSTARMIN | wc -l)
if [ "\$VEXECRESUME" -gt "0" ]; then
ResumeServerManager
fi;
fi;
sleep 5
done

fi;

done
break
fi;



sleep 5;
done

JBEOF
