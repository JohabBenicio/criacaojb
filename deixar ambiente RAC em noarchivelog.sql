

ps -ef |  grep smon | grep MAXYSH


Dados de Contato
Nome:	Henrique Franzão 34 3293-6681 r. 4081
Email:	h.franzao@sodru.com



Desligado

38794 - ambiente MAXYSMH
Dados da Solicitação
Cliente:	SODRUGESTVO GROUP
Ambiente:	Produção Oracle
Abertura:	29/05/2015 09:49
Encerramento:	29/05/2015 14:53
Status:	Encerrado TEOR
Prioridade:	P4-Ambiente Operacional, Sem Falhas
Descrição:	Baixar o ambiente MAXYSMH pois no esta sendo utilizada



Paulo Roberto


INSTANCIA       RAC STATUS          DATABASE  OPEN MODE   MODO ARCHIVE    VERSAO
--------------- --- --------------- --------- ----------- --------------- ----------------------------------------------------------
MAXYSH1         YES OPEN            MAXYS_HO  READ WRITE  ARCHIVELOG      Oracle Database 10g Release 10.2.0.5.0 - 64bit Production


srvctl status database -d "MAXYS_HOMOLOG"
Instance MAXYSH1 is running on node br-s-ora01
Instance MAXYSH2 is running on node br-s-ora02


srvctl stop database -d "MAXYS_HOMOLOG"

srvctl start database -d "MAXYS_HOMOLOG" -o "mount"

alter database noarchivelog

srvctl stop database -d "MAXYS_HOMOLOG"

srvctl start database -d "MAXYS_HOMOLOG"
