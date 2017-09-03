function analise_verao {
echo -e "\nANALISE ZIC\n==========="
CONF1="/etc/localtime  Sun Feb 21 01:59:59 2016 UTC = Sat Feb 20 23:59:59 2016 BRST isdst=1 gmtoff=-7200"
CONF2="/etc/localtime  Sun Feb 21 02:00:00 2016 UTC = Sat Feb 20 23:00:00 2016 BRT isdst=0 gmtoff=-10800"
/usr/sbin/zdump  -v /etc/localtime | grep 2016 | grep -e "$CONF1\|$CONF2"
echo -e "\nANALISE NTP\n==========="
/sbin/service ntpd status
echo -e "\n"
}

analise_verao


