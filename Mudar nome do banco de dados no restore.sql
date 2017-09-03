1) Apenas restaure  banco de dados e aplique os archives
2) Entre no sqlplus e emitao seguinte comando "alter database backup controlfile to trace as '/tmp/contrlfile_trace.sql';"
3) Edite o arquivo mantendo apenas o que interesa e mudando o nome do banco de dados.

Original: CREATE CONTROLFILE REUSE DATABASE "PROD" NORESETLOGS  ARCHIVELOG
Modificado: CREATE CONTROLFILE SET DATABASE "HOMO" RESETLOGS NOARCHIVELOG

Exemplo do arquivo editado:
[oracle@napebsdbhom01 [homo] backup]$ cat /tmp/contrlfile_trace.sql
CREATE CONTROLFILE SET DATABASE "HOMO" RESETLOGS  NOARCHIVELOG
    MAXLOGFILES 32
    MAXLOGMEMBERS 5
    MAXDATAFILES 512
    MAXINSTANCES 8
    MAXLOGHISTORY 14607
LOGFILE
  GROUP 1 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 2 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 3 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 4 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 5 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 6 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 7 '+DGDATA01'  SIZE 500M BLOCKSIZE 512,
  GROUP 8 '+DGDATA01'  SIZE 500M BLOCKSIZE 512
DATAFILE
  '+DGDATA01/prod/datafile/system.514.914178829',
  (...)
  '+DGDATA01/prod/datafile/apps_ts_tx_idx.467.914171515',
  '+DGDATA01/prod/datafile/apps_ts_tx_idx.437.914169731',
  '+DGDATA01/prod/datafile/apps_ts_tx_idx.494.914175943',
  '+DGDATA01/prod/datafile/apps_ts_seed.338.914156595'
CHARACTER SET WE8ISO8859P1
;


4) Depois de criar o arquivo e editar, então atualize o nome do controlfle: "alter system set control_files='+DGDATA01' scope=spfile;"
5) Modifique o nome do db_name para o novo nome do database: "alter system set db_name='HOMO' scope=spfile;"
5) Baixe a instancia e suba em modo "NOMOUNT" e execute o arquivo para recriar o controlfile com novo nome.


################################################################################################################################################

SQL> alter system set control_files='+DGDATA01' scope=spfile;

System altered.

SQL> alter system set db_name='HOMO' scope=spfile;

System altered.

SQL> shut immediate;
ORA-01507: database not mounted

ORACLE instance shut down.

SQL> startup nomount;
ORACLE instance started.

Total System Global Area 3.4206E+10 bytes
Fixed Size                  2245480 bytes
Variable Size            2415922328 bytes
Database Buffers         3.1742E+10 bytes
Redo Buffers               45674496 bytes
SQL> @/tmp/contrlfile_trace.sql

Control file created.

SQL> alter database open RESETLOGS;

Database altered.
