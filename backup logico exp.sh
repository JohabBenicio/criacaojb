rm -f exp_full.sh
vi exp_full.sh
i

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
# Atualizado em 28/10/2014
#
# Efetua backup full do banco de dados utilizando utilitario EXPDP
#
# Versao para Linux
# $1 ORACLE_SID

#
# Inicio
#

BASH=~/.bash_profile

if [ -e "$BASH" ]; then
  . $BASH
else
  BASH=~/.profile
  . $BASH
fi

#######################################################################
# VARIAVEIS DE GLOBAIS                                                |
#######################################################################
# 

ps -ef | grep smon | grep $1 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | while read instance_db
do
if [ "$instance_db" = "$1" ]; then
  echo "$instance_db">/tmp/expbanco.log
fi
done

if [ -e "/tmp/expbanco.log" ]; then
  BANCO=$(cat /tmp/expbanco.log 2>>/dev/null)
  rm -f /tmp/expbanco.log
fi

if [ -z "$1" ]; then
   echo -e "\n\nDigite: sh expdp_full.sh <SID> <DIRECTORY> ou expdp_full.sh <SID> <DIRECTORY> \n\n" 
   exit 
elif [ "$BANCO" = "$1" ]; then
   export ORACLE_SID=$1
else
   echo "Banco nao existe"
   exit
fi

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

#######################################################################
# LOCAL DAS PEÇAS DE BACKUP                                           |
#######################################################################
#
DIR=/u02/backup/prod/database/bkp_logico

DAT=`date +"%w_%d%m%y"`
DESTINO=exp_full_$ORACLE_SID
BKPLOG=$DESTINO\_$DAT.log
BKPPAR=$DIR/$DESTINO\_$DAT.par


#######################################################################
# RETENCAO DO BACKUP                                                  |
#######################################################################
#
find $DIR -type f -name "*.gz" -mtime +1 -exec rm -f {} \; 
find $DIR -type f -name "*.log" -mtime +10 -exec rm -f {} \;

#
BKPTAR1=$DIR/$DESTINO\_$DAT\_01.tar.gz; BKPTAR2=$DIR/$DESTINO\_$DAT\_02.tar.gz
BKPTAR3=$DIR/$DESTINO\_$DAT\_03.tar.gz; BKPTAR4=$DIR/$DESTINO\_$DAT\_04.tar.gz
BKPTAR5=$DIR/$DESTINO\_$DAT\_05.tar.gz; BKPTAR6=$DIR/$DESTINO\_$DAT\_06.tar.gz
BKPTAR7=$DIR/$DESTINO\_$DAT\_07.tar.gz; BKPTAR8=$DIR/$DESTINO\_$DAT\_08.tar.gz
BKPTAR9=$DIR/$DESTINO\_$DAT\_09.tar.gz; BKPTAR10=$DIR/$DESTINO\_$DAT\_10.tar.gz
BKPTAR11=$DIR/$DESTINO\_$DAT\_11.tar.gz; BKPTAR12=$DIR/$DESTINO\_$DAT\_12.tar.gz
BKPTAR13=$DIR/$DESTINO\_$DAT\_13.tar.gz; BKPTAR14=$DIR/$DESTINO\_$DAT\_14.tar.gz
BKPTAR15=$DIR/$DESTINO\_$DAT\_15.tar.gz; BKPTAR16=$DIR/$DESTINO\_$DAT\_16.tar.gz
BKPTAR17=$DIR/$DESTINO\_$DAT\_17.tar.gz; BKPTAR18=$DIR/$DESTINO\_$DAT\_18.tar.gz
BKPTAR19=$DIR/$DESTINO\_$DAT\_19.tar.gz; BKPTAR20=$DIR/$DESTINO\_$DAT\_20.tar.gz
BKPTAR21=$DIR/$DESTINO\_$DAT\_21.tar.gz; BKPTAR22=$DIR/$DESTINO\_$DAT\_22.tar.gz
BKPTAR23=$DIR/$DESTINO\_$DAT\_23.tar.gz; BKPTAR24=$DIR/$DESTINO\_$DAT\_24.tar.gz
BKPTAR25=$DIR/$DESTINO\_$DAT\_25.tar.gz; BKPTAR26=$DIR/$DESTINO\_$DAT\_26.tar.gz
BKPTAR27=$DIR/$DESTINO\_$DAT\_27.tar.gz; BKPTAR28=$DIR/$DESTINO\_$DAT\_28.tar.gz
BKPTAR29=$DIR/$DESTINO\_$DAT\_29.tar.gz; BKPTAR30=$DIR/$DESTINO\_$DAT\_30.tar.gz

#
BKPDMP1=$DESTINO\_$DAT\_01.dmp; BKPDMP2=$DESTINO\_$DAT\_02.dmp
BKPDMP3=$DESTINO\_$DAT\_03.dmp; BKPDMP4=$DESTINO\_$DAT\_04.dmp
BKPDMP5=$DESTINO\_$DAT\_05.dmp; BKPDMP6=$DESTINO\_$DAT\_06.dmp
BKPDMP7=$DESTINO\_$DAT\_07.dmp; BKPDMP8=$DESTINO\_$DAT\_08.dmp
BKPDMP9=$DESTINO\_$DAT\_09.dmp; BKPDMP10=$DESTINO\_$DAT\_10.dmp
BKPDMP11=$DESTINO\_$DAT\_11.dmp; BKPDMP12=$DESTINO\_$DAT\_12.dmp
BKPDMP13=$DESTINO\_$DAT\_13.dmp; BKPDMP14=$DESTINO\_$DAT\_14.dmp
BKPDMP15=$DESTINO\_$DAT\_15.dmp; BKPDMP16=$DESTINO\_$DAT\_16.dmp
BKPDMP17=$DESTINO\_$DAT\_17.dmp; BKPDMP18=$DESTINO\_$DAT\_18.dmp
BKPDMP19=$DESTINO\_$DAT\_19.dmp; BKPDMP20=$DESTINO\_$DAT\_20.dmp
BKPDMP21=$DESTINO\_$DAT\_21.dmp; BKPDMP22=$DESTINO\_$DAT\_22.dmp
BKPDMP23=$DESTINO\_$DAT\_23.dmp; BKPDMP24=$DESTINO\_$DAT\_24.dmp
BKPDMP25=$DESTINO\_$DAT\_25.dmp; BKPDMP26=$DESTINO\_$DAT\_26.dmp
BKPDMP27=$DESTINO\_$DAT\_27.dmp; BKPDMP28=$DESTINO\_$DAT\_28.dmp
BKPDMP29=$DESTINO\_$DAT\_29.dmp; BKPDMP30=$DESTINO\_$DAT\_30.dmp


  echo "userid=system/systemusd2003"       >  ${BKPPAR}
  echo "file=$DIR/$BKPDMP1"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP2"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP3"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP4"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP5"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP6"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP7"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP8"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP9"                >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP10"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP12"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP13"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP14"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP15"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP16"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP17"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP18"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP19"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP20"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP21"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP22"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP23"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP24"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP25"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP26"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP27"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP28"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP29"               >> ${BKPPAR}
  echo "file=$DIR/$BKPDMP30"               >> ${BKPPAR}
  echo "statistics=none"                   >> ${BKPPAR}
  echo "filesize=2048M"                    >> ${BKPPAR}
  echo "log=$DIR/$BKPLOG"                  >> ${BKPPAR}
  echo "full=Y"                            >> ${BKPPAR}


#exp \'/ as sysdba\' full=Y file=$DIR/$BKPDMP log=$DIR/$BKPLOG FILESIZE=1m
exp PARFILE=$BKPPAR

if [ -f $DIR/$BKPDMP1 ]
then
   tar -cvzf $BKPTAR1 $DIR/$BKPDMP1 $DIR/$BKPLOG $BKPPAR
   rm -f $DIR/$BKPDMP1 $BKPPAR
fi

if [ -f $DIR/$BKPDMP2 ]
then
   tar -cvzf $BKPTAR2 $DIR/$BKPDMP2
   rm -f $DIR/$BKPDMP2
fi

if [ -f $DIR/$BKPDMP3 ]
then
   tar -cvzf $BKPTAR3 $DIR/$BKPDMP3
   rm -f $DIR/$BKPDMP3
fi

if [ -f $DIR/$BKPDMP4 ]
then
   tar -cvzf $BKPTAR4 $DIR/$BKPDMP4
   rm -f $DIR/$BKPDMP4
fi

if [ -f $DIR/$BKPDMP5 ]
then
   tar -cvzf $BKPTAR5 $DIR/$BKPDMP5
   rm -f $DIR/$BKPDMP5
fi

if [ -f $DIR/$BKPDMP6 ]
then
   tar -cvzf $BKPTAR6 $DIR/$BKPDMP6
   rm -f $DIR/$BKPDMP6
fi

if [ -f $DIR/$BKPDMP7 ]
then
   tar -cvzf $BKPTAR7 $DIR/$BKPDMP7
   rm -f $DIR/$BKPDMP7
fi

if [ -f $DIR/$BKPDMP8 ]
then
   tar -cvzf $BKPTAR8 $DIR/$BKPDMP8
   rm -f $DIR/$BKPDMP8
fi

if [ -f $DIR/$BKPDMP9 ]
then
   tar -cvzf $BKPTAR9 $DIR/$BKPDMP9
   rm -f $DIR/$BKPDMP9
fi

if [ -f $DIR/$BKPDMP10 ]
then
   tar -cvzf $BKPTAR10 $DIR/$BKPDMP10
   rm -f $DIR/$BKPDMP10
fi

if [ -f $DIR/$BKPDMP11 ]
then
   tar -cvzf $BKPTAR11 $DIR/$BKPDMP11
   rm -f $DIR/$BKPDMP11
fi

if [ -f $DIR/$BKPDMP12 ]
then
   tar -cvzf $BKPTAR12 $DIR/$BKPDMP12
   rm -f $DIR/$BKPDMP12
fi

if [ -f $DIR/$BKPDMP13 ]
then
   tar -cvzf $BKPTAR13 $DIR/$BKPDMP13
   rm -f $DIR/$BKPDMP13
fi

if [ -f $DIR/$BKPDMP14 ]
then
   tar -cvzf $BKPTAR14 $DIR/$BKPDMP14
   rm -f $DIR/$BKPDMP14
fi

if [ -f $DIR/$BKPDMP15 ]
then
   tar -cvzf $BKPTAR15 $DIR/$BKPDMP15
   rm -f $DIR/$BKPDMP15
fi

if [ -f $DIR/$BKPDMP16 ]
then
   tar -cvzf $BKPTAR16 $DIR/$BKPDMP16
   rm -f $DIR/$BKPDMP16
fi

if [ -f $DIR/$BKPDMP17 ]
then
   tar -cvzf $BKPTAR17 $DIR/$BKPDMP17
   rm -f $DIR/$BKPDMP17
fi

if [ -f $DIR/$BKPDMP18 ]
then
   tar -cvzf $BKPTAR18 $DIR/$BKPDMP18
   rm -f $DIR/$BKPDMP18
fi

if [ -f $DIR/$BKPDMP19 ]
then
   tar -cvzf $BKPTAR19 $DIR/$BKPDMP19
   rm -f $DIR/$BKPDMP19
fi

if [ -f $DIR/$BKPDMP20 ]
then
   tar -cvzf $BKPTAR20 $DIR/$BKPDMP20
   rm -f $DIR/$BKPDMP20
fi

if [ -f $DIR/$BKPDMP21 ]
then
   tar -cvzf $BKPTAR21 $DIR/$BKPDMP21
   rm -f $DIR/$BKPDMP21
fi

if [ -f $DIR/$BKPDMP22 ]
then
   tar -cvzf $BKPTAR22 $DIR/$BKPDMP22
   rm -f $DIR/$BKPDMP22
fi

if [ -f $DIR/$BKPDMP23 ]
then
   tar -cvzf $BKPTAR23 $DIR/$BKPDMP23
   rm -f $DIR/$BKPDMP23
fi

if [ -f $DIR/$BKPDMP24 ]
then
   tar -cvzf $BKPTAR24 $DIR/$BKPDMP24
   rm -f $DIR/$BKPDMP24
fi

if [ -f $DIR/$BKPDMP25 ]
then
   tar -cvzf $BKPTAR25 $DIR/$BKPDMP25
   rm -f $DIR/$BKPDMP25
fi

if [ -f $DIR/$BKPDMP26 ]
then
   tar -cvzf $BKPTAR26 $DIR/$BKPDMP26
   rm -f $DIR/$BKPDMP26
fi

if [ -f $DIR/$BKPDMP27 ]
then
   tar -cvzf $BKPTAR27 $DIR/$BKPDMP27
   rm -f $DIR/$BKPDMP27
fi

if [ -f $DIR/$BKPDMP28 ]
then
   tar -cvzf $BKPTAR28 $DIR/$BKPDMP28
   rm -f $DIR/$BKPDMP28
fi

if [ -f $DIR/$BKPDMP29 ]
then
   tar -cvzf $BKPTAR29 $DIR/$BKPDMP29
   rm -f $DIR/$BKPDMP29
fi

if [ -f $DIR/$BKPDMP30 ]
then
   tar -cvzf $BKPTAR30 $DIR/$BKPDMP30
   rm -f $DIR/$BKPDMP30
fi






