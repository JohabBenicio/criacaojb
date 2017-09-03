if [ "$(uname)" == "Linux" ]; then
function analise_verao {
cat <<EOF
NOME DO SERVER
==============
$(hostname)
EOF
CONF1="/etc/localtime  Sun Feb 19 01:59:59 2017 UTC = Sat Feb 18 23:59:59 2017 BRST isdst=1"
CONF2="/etc/localtime  Sun Feb 19 02:00:00 2017 UTC = Sat Feb 18 23:00:00 2017 BRT isdst=0"
VALID=$(/usr/sbin/zdump  -v /etc/localtime | grep $(date +"%Y") | wc -l)
if [ "$VALID" -gt "0" ]; then
VALID1=$(/usr/sbin/zdump  -v /etc/localtime | grep  $(date +"%Y") | grep -e "Oct\|Feb" | grep -e "$CONF1\|$CONF2" | wc -l)
if [ "$VALID1" -gt "0" ]; then
echo -e "\nANALISE ZIC\n==========="
cat <<EOF
Esta CERTO

EOF
/usr/sbin/zdump  -v /etc/localtime | grep  $(date +"%Y") | grep -e "Oct\|Feb" | grep -e "$CONF1\|$CONF2"
else
echo -e "\nANALISE ZIC\n==========="
cat <<EOF
Esta ERRADO............ERRADO............ERRADO............ERRADO
    Esta ERRADO............ERRADO............ERRADO............ERRADO
Esta ERRADO............ERRADO............ERRADO............ERRADO
    Esta ERRADO............ERRADO............ERRADO............ERRADO

EOF
/usr/sbin/zdump  -v /etc/localtime | grep  $(date +"%Y")
fi
else
echo "ZIC nao configurado"
fi
echo -e "\nANALISE NTP\n==========="
/sbin/service ntpd status 2>>/dev/null
if [ "$?" -eq "1" ]; then
/sbin/service ntp status 2>>/dev/null
if [ "$?" -eq "1" ]; then
echo "Nao esta configurado NTPD e nem NTP"
else
cat <<EOF

EOF
ntpstat 2>>/dev/null
fi
else
cat <<EOF

EOF
ntpstat 2>>/dev/null
fi
echo -e "\nDATA ATUAL\n==========="
date
echo -e "\n"
}
analise_verao
else
echo -e "\nANALISE ZIC\n==========="
ZONE=$(cat /etc/environment | grep TZ | cut -d "=" -f 2)
zdump -v /usr/share/lib/zoneinfo/$ZONE | grep  $(date +"%Y")
echo -e "\nANALISE NTP\n==========="
ps -ef | grep ntp | grep -v grep
echo -e "\nDATA ATUAL\n==========="
date
fi



















Horário de verão
##################################################################
Passo 1) Execute o comando abaixo e valide a saída. Caso não esteja igual, então prossiga com o passo 2.

zdump -v /etc/localtime | grep "$(date +"%Y")\|$(($(date +"%Y")+1))"

/etc/localtime  Sun Oct 16 02:59:59 2016 UTC = Sat Oct 15 23:59:59 2016 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 16 03:00:00 2016 UTC = Sun Oct 16 01:00:00 2016 BRST isdst=1 gmtoff=-7200
/etc/localtime  Sun Feb 19 01:59:59 2017 UTC = Sat Feb 18 23:59:59 2017 BRST isdst=1 gmtoff=-7200
/etc/localtime  Sun Feb 19 02:00:00 2017 UTC = Sat Feb 18 23:00:00 2017 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 15 02:59:59 2017 UTC = Sat Oct 14 23:59:59 2017 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 15 03:00:00 2017 UTC = Sun Oct 15 01:00:00 2017 BRST isdst=1 gmtoff=-7200


Caso esteja igual, então não faça mais nada.

##################################################################
Passo 2) - Criação do script para o ajuste do ZIC.

cat <<EOF> /tmp/verao.zic
Rule Brazil 2016 only - Feb 21 00:00 0 -
Rule Brazil 2016 only - Oct 16 00:00 1 S
Rule Brazil 2017 only - Feb 19 00:00 0 -
Rule Brazil 2017 only - Oct 15 00:00 1 S
Rule Brazil 2018 only - Feb 18 00:00 0 -
Rule Brazil 2018 only - Oct 21 00:00 1 S
Rule Brazil 2019 only - Feb 17 00:00 0 -
Rule Brazil 2019 only - Oct 20 00:00 1 S
Rule Brazil 2020 only - Feb 16 00:00 0 -
Rule Brazil 2020 only - Oct 18 00:00 1 S
Zone Brazil/East -3:00 Brazil BR%sT
EOF

##################################################################
Passo 3) - Atualização do ZoneInfo

zic /tmp/verao.zic

##################################################################
Passo 4) - Backup do localtime

cp /etc/localtime /etc/localtime_$(date +"%d_%m_%Y").bkp

##################################################################
Passo 5) - Atualização do localtime

rm -f /etc/localtime
cp /usr/share/zoneinfo/Brazil/East /etc/localtime

