

srvctl stop instance -d hcb -i hcb1



ser root da máquina. O comando é: 

 screen 

Em algumas instalações, uma tela de about será mostrada com uma mensagem de pressionar algo para finalizar. Finalizaremos a tela de about e cairemos na nossa sessão screen. Se o usuário já tiver uma sessão screen rodando e utilizar o comando acima, outra sessão será criada. 

2) Acessando uma sessão screen anteriormente criada 

 screen -x 

There are several suitable screens on:
~ 9984.pts-1.rimmon (Detached)
~ 9966.pts-1.rimmon (Detached)
~ 9948.pts-1.rimmon (Detached)
Type "screen [-d] -r [pid.]tty.host" to resume one of them. 

Vejamos que há um comentário dizendo que a sessão está "Detached". Sessões Attached estão sendo utilizadas nesse momento, enquanto Detached são sessões das quais o usuário se desconectou, sem encerrá-las. 

Fazendo: 

 screen -r 9984.pts-1.rimmon 

A sessão entrará em estado attached e trabalharemos com ela. O comando: 

 screen -d 9984.pts-1.rimmon 


 [oracle@piodb01 ~]$ srvctl start database -d hcb
PRCC-1014 : hcb was already running
PRCR-1004 : Resource ora.hcb.db is already running
PRCR-1079 : Failed to start resource ora.hcb.db
CRS-2800: Cannot start resource 'ora.DGDATA.dg' as it is already in the INTERMEDIATE state on server 'piodb01'
CRS-2528: Unable to place an instance of 'ora.hcb.db' as all possible servers are occupied by the resource



ssh piodb01

 screen -x 


 srvctl start instance -d hcb -n piodb01


 srvctl stop asm -n piodb01
srvctl start asm -n piodb01


Tentativa de baixar ao CRS para realocação da memoria, porém, õ mesmo não foi possivel.






AÇÕES EXECUTADAS (resumo)
====================
1) - Analise do estado do listener.
* Listener online há 3 dias.

DADOS COLETADOS
==============
1) - Status do listener.

[oracle@piodb01 ~]$ srvctl status listener
Listener LISTENER is enabled
Listener LISTENER is running on node(s): piodb01,piodb02


[oracle@piodb01 ~]$ lsnrctl status

LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 04-DEC-2016 00:35:04

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                30-NOV-2016 17:08:30
Uptime                    3 days 7 hr. 26 min. 34 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/11.2.0/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/piodb01/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.16.1.84)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "hcb" has 1 instance(s).
  Instance "hcb1", status READY, has 1 handler(s) for this service...
Service "hcbtaf" has 1 instance(s).
  Instance "hcb1", status READY, has 1 handler(s) for this service...
The command completed successfully



Com base nos dados coletados, podemos afirmar o listener se encontra online.
Estamos encaminhando este chamado para o encerramento.


Att,
Johab Benicio.
DBA Oracle.


Celso.


Robson.





AÇÕES EXECUTADAS (resumo)
=========================
1) - Analise do log de execução do processo.
* Identificamos que o Oracle não esta conseguindo alocar memoria para concluir as atividades no node 1 do RAC.
2) - Restart do banco de dados para re-alocação de memoria.
* Oracle não conseguiu alocar memoria para subir a instancia;
3) - Restart do CRS a fim de reiniciar o Oracle para re-alocação de memória;
* Oracle não conseguiu alocar memoria concluir a parada do cluster.
4) - Restart do servidor piodb01 para força o Orcle a reiniciar e realocar a memória.
* Processo de shutdown travou. (Causa provavel: Oracle não conseguiu alocar memoria para a parada dos processos do Oracle.)



DADOS COLETADOS
===============
ORA-04031: unable to allocate 760 bytes of shared memory ("shared pool","unknown object","KKSSP^731","kglss")







AÇÕES EXECUTADAS (resumo)
=========================
1) - Analise do log de execução do processo.
* Identificamos que o Oracle não esta conseguindo alocar memoria para concluir as atividades no node 1 do RAC.
2) - Restart do banco de dados para re-alocação de memoria.
* Oracle não conseguiu alocar memoria para subir a instancia;
3) - Restart do CRS a fim de reiniciar o Oracle para re-alocação de memória;
* Oracle não conseguiu alocar memoria concluir a parada do cluster.
4) - Restart do servidor piodb01 para força o Oracle a reiniciar e realocar a memória.
* Processo de shutdown travou. (Causa provável: Oracle não conseguiu alocar memoria para a parada dos processos do Oracle.)
5) - Cliente reiniciou os servidores manualmente com auxilio da Teor;
6) - Validação da execução do backup diário;
7) - Liberação do ambiente para o cliente.


CHAMADA TELEFÔNICA AO CLIENTE
========================
Contato telefônico com o cliente em 04/12/2016 02:10, no número (17) 997-071-651.

1) - Solicitamos ao cliente a realização do restart do servidor manualmente, pois o processo travou durante o shutdown.


DADOS COLETADOS
================
1) - Status do banco de dados;

Nome da instancia:............ hcb1
Nome do banco de dados:....... HCB
Status do banco:.............. OPEN
Startup Time:................. 04/12/2016 03:18
Open Mode:.................... READ WRITE
Modo Archive:................. ARCHIVELOG
Versao do RDBMS:.............. Oracle Database 11g Release 11.2.0.3.0 - 64bit Production

Nome da instancia:............ hcb2
Nome do banco de dados:....... HCB
Status do banco:.............. OPEN
Startup Time:................. 04/12/2016 03:29
Open Mode:.................... READ WRITE
Modo Archive:................. ARCHIVELOG
Versao do RDBMS:.............. Oracle Database 11g Release 11.2.0.3.0 - 64bit Production


2) - Status do listener.

[oracle@piodb02 ~]$ srvctl status listener
Listener LISTENER is enabled
Listener LISTENER is running on node(s): piodb01,piodb02


Com base nos dados coletados, podemos afirmar que seu ambiente se encontra operacional.
Estamos encaminhando este chamado para o encerramento.



Att,
Johab Benicio.
DBA Oracle.
