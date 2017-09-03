#!/bin/bash

####################################################################
#
# VARIAVEIS A SEREM AJUSTADAS NO SERVIDOR DO CLIENTE
#
####################################################################

LSOF=/usr/sbin/lsof
ZIP=/usr/bin/zip
TMA_DIR=/udump/tma/
CLIENT_ALIAS=SaoFrancisco_bdp04


####################################################################
#
# ponto de entrada
#
####################################################################


#
# verifica parametro de entrada
#
if [ "$1" == "" ];
  then
    echo "Uso: packAndUploadTraces.sh <diretorio_udump>"
    exit 1
  fi

test -d $1
if [ $? -gt 0 ];
  then
    echo "$1 n�o � um diret�rio de traces v�lido"
    exit 1
  fi

test -d $TMA_DIR
if [ $? -gt 0 ];
  then
    echo "$WORK_DIR n�o � um diret�rio v�lido para uso pelo TMA"
    exit 1
  fi

export WORK_DIR=$TMA_DIR/work
export AGING_DIR=$TMA_DIR/aging

test -d $WORK_DIR
if [ $? -gt 0 ];
  then
    mkdir -p $WORK_DIR
    if [ $? -gt 0 ];
      then
        echo "n�o foi poss�vel criar um diret�rio de trabalho em $TMA_DIR"
        exit 1
      fi
  fi

test -d $AGING_DIR
if [ $? -gt 0 ];
  then
    mkdir $AGING_DIR
    if [ $? -gt 0 ];
      then
        echo "n�o foi poss�vel criar um diret�rio de aging em $TMA_DIR"
        exit 1
      fi
  fi

export UDUMP_DIR=$1
export TMPLIST=/tmp/open_traces

#
# gera uma lista contendo todos os arquivos trace abertos
#
echo -n "Gerando lista de arquivos trace abertos..."
rm -f $TMPLIST
$LSOF | grep TEOR | grep trc > $TMPLIST
if [ $? -gt 0 ];
  then
    echo "Erro!"
    exit 1
  fi
echo "Ok!"


#
# cria o o diret�rio para receber os arquivos ZIP
#
echo -n "Criando diretorio para arquivos trace..."
export ZIP_DIR=$(date +%Y%m%d_%H%M)
export ZIP_FILE=$CLIENT_ALIAS\_$ZIP_DIR.tar.gz
mkdir $WORK_DIR/$ZIP_DIR
if [ $? -gt 0 ];
  then
    echo "Falha!"
    exit 1
  fi
echo "Ok!"

#
# move todos os traces fechados para o diretorio que foi criado
#
echo -n "Movendo arquivos trace fechados para o diret�rio $ZIP_DIR..."
ls -1 $UDUMP_DIR/*TEOR*.trc | while read f
  do
    grep "$f" $TMPLIST &>/dev/null
    if [ $? -gt 0 ];
      then
        mv $f $WORK_DIR/$ZIP_DIR
      fi
  done
echo "Ok!"

#
# compacta a pasta contendo os arquivos trace
#
echo -n "Compactando pasta de traces $ZIP_DIR..."
cd $WORK_DIR
tar -cvzf $ZIP_FILE $ZIP_DIR
if [ $? -gt 0 ];
  then
    echo "Falha!"
    exit 1
  fi
rm -rf $ZIP_DIR
echo "Ok!"

#
# Efetuando upload para a TEOR
#
echo -n "Subindo arquivos para a TEOR..."
ls -1 *.[tz]* | while read line
  do
    curl -T $WORK_DIR/$line ftp://stage.teor.inf.br --user teor:ftp@t30r 1>/dev/null 2>&1
    if [ $? -eq 0 ];
      then
        mv $WORK_DIR/$line $AGING_DIR
        echo "Arquivo $line ok"
      else
        echo "Arquio $line apresentou erro na transferia. Fica pendente"
      fi
  done

#
# Limpa arquivos antigos
#
cd $AGING_DIR
find *.*z* -mtime +5 -exec rm {} \;

