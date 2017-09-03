
########################################################################################
## Rodar o scan do Linux (Procedimento abaixo para Linux 4)
# Executar nos servidores do RAC

multipath -l | grep "(" | grep ")"; multipath -l | grep "(" | grep ")" | wc -l


for i in `ls -1 /sys/class/fc_host`; do
echo "1" > /sys/class/fc_host/${i}/issue_lip
done

for i in `ls -1 /sys/class/scsi_host`; do
echo "- - -" > /sys/class/scsi_host/${i}/scan
done

########################################################################################
## Identificar as novas LUNs
# Executar nos servidores do RAC

multipath -ll | grep "(" | grep ")" | sort

asm01_DSK (36005076802810c155800000000000026) dm-4 IBM,2145
asm02_DSK (36005076802810c155800000000000025) dm-3 IBM,2145
asm03_DSK (36005076802810c155800000000000024) dm-2 IBM,2145
asm04_DSK (36005076802810c155800000000000027) dm-5 IBM,2145
asm05_DSK (36005076802810c155800000000000028) dm-6 IBM,2145
asm06_DSK (36005076802810c155800000000000029) dm-7 IBM,2145
asm07_DSK (36005076802810c15580000000000002a) dm-8 IBM,2145
asm08_DSK (36005076802810c15580000000000002c) dm-1 IBM,2145
asm09_DSK (36005076802810c15580000000000002b) dm-0 IBM,2145
mpath6 (36005076802810c155800000000000032) dm-18 IBM,2145
mpath7 (36005076802810c155800000000000033) dm-19 IBM,2145
mpath8 (36005076802810c155800000000000034) dm-20 IBM,2145



########################################################################################
## Adicionar o apelido seguindo o padrão do servidor
# Executar nos servidores do RAC

       multipath {
                wwid 36005076802810c155800000000000032
                alias asm10_DSK
       }
       multipath {
                wwid 36005076802810c155800000000000033
                alias asm11_DSK
       }
       multipath {
                wwid 36005076802810c155800000000000034
                alias asm12_DSK
       }


########################################################################################
## Comando abaixo vai fazer algo semelhante ao reload, ele vai somente reconhecer as novas LUNs com o novo apelido.
# Executar nos servidores do RAC

multipath -v2


########################################################################################
## Comando abaixo vai fazer algo semelhante ao reload, ele vai somente reconhecer as novas LUNs com o novo apelido.
# Executar nos servidores do RAC


multipath -ll | grep "(" | grep ")" | sort

ls -thr  /dev/mapper/asm* | sort

/dev/mapper/asm01_DSK
/dev/mapper/asm01_DSKp1
/dev/mapper/asm02_DSK
/dev/mapper/asm02_DSKp1
/dev/mapper/asm03_DSK
/dev/mapper/asm03_DSKp1
/dev/mapper/asm04_DSK
/dev/mapper/asm04_DSKp1
/dev/mapper/asm05_DSK
/dev/mapper/asm05_DSKp1
/dev/mapper/asm06_DSK
/dev/mapper/asm06_DSKp1
/dev/mapper/asm07_DSK
/dev/mapper/asm07_DSKp1
/dev/mapper/asm08_DSK
/dev/mapper/asm08_DSKp1
/dev/mapper/asm09_DSK
/dev/mapper/asm09_DSKp1
/dev/mapper/asm10_DSK
/dev/mapper/asm11_DSK
/dev/mapper/asm12_DSK




########################################################################################
## Formatar os novos discos
# (APENAS EM UM SERVIDOR)

fdisk /dev/mapper/asm10_DSK
fdisk /dev/mapper/asm11_DSK
fdisk /dev/mapper/asm12_DSK


########################################################################################
## Adicionar a partição para os discos sem a necessidade do restart do servidor.
# Executar nos servidores do RAC


kpartx -a /dev/mapper/asm10_DSK
kpartx -a /dev/mapper/asm11_DSK
kpartx -a /dev/mapper/asm12_DSK



ls -thr  /dev/mapper/asm* | sort



########################################################################################
## Conceder permissão para para o usuario ORACLE.
# Executar nos servidores do RAC
# (APENAS SE NAO ESTIVER UTILIZANDO O ASMLIB)

chown oracle.dba /dev/mapper/asm*p1




########################################################################################
## Apresentar os discos para o ASM.
# (APENAS EM UM SERVIDOR)


export ORAENV_ASK=NO ; ORACLE_SID=+ASM2 ; . oraenv; export ORAENV_ASK=YES

sqlplus / as sysdba


-- +--------------------------------------------------------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |--------------------------------------------------------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2007 Jeffrey M. Hunter. All rights reserved.       |
-- |--------------------------------------------------------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_disks.sql                                                   |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all disks contained within all disk |
-- |            groups. This script is also responsible for queriing all        |
-- |            candidate disks - those that are not assigned to any disk       |
-- |            group.                                                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +--------------------------------------------------------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20           HEAD 'Disk Group Name'
COLUMN disk_file_path         FORMAT a25           HEAD 'Path'
COLUMN disk_file_name         FORMAT a20           HEAD 'File Name'
COLUMN disk_file_fail_group   FORMAT a20           HEAD 'Fail Group'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'File Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

break on report on disk_group_name skip 1

compute sum label ""              of total_mb used_mb on disk_group_name
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    NVL(a.name, '[CANDIDATE]')                       disk_group_name
  , b.path                                           disk_file_path
  , b.name                                           disk_file_name
  , b.failgroup                                      disk_file_fail_group
  , b.total_mb                                       total_mb
  , (b.total_mb - b.free_mb)                         used_mb
  , ROUND((1- (b.free_mb / b.total_mb))*100, 2)      pct_used
FROM
    v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number)
ORDER BY
    a.name,b.name,b.path
/





################################################## Resultado ##################################################




Disk Group Name      Path                      File Name            Fail Group           File Size (MB) Used Size (MB) Pct. Used
-------------------- ------------------------- -------------------- -------------------- -------------- -------------- ---------
DATA01               /dev/mapper/asmdata01p1   DATA01_0008          DATA01_0008                  81,917         63,734     77.80
                     /dev/mapper/asmdata02p1   DATA01_0009          DATA01_0009                  81,917         63,729     77.80
                     /dev/mapper/asmdata03p1   DATA01_0010          DATA01_0010                  81,917         63,739     77.81
                     /dev/mapper/asmdata04p1   DATA01_0011          DATA01_0011                  81,917         63,734     77.80
                     /dev/mapper/asmdata05p1   DATA01_0012          DATA01_0012                  81,917         63,726     77.79
                     /dev/mapper/asmdata06p1   DATA01_0013          DATA01_0013                  82,937         64,858     78.20
                     /dev/mapper/asmdata07p1   DATA01_0014          DATA01_0014                  81,917         63,722     77.79
                     /dev/mapper/asmdata08p1   DATA01_0015          DATA01_0015                  81,917         63,740     77.81
********************                                                                     -------------- --------------
                                                                                                656,356        510,982

[CANDIDATE]          /dev/mapper/asmdata09p1                                                     81,917         81,917    100.00
                     /dev/mapper/asmdata10p1                                                     81,917         81,917    100.00
                     /dev/mapper/asmdata11p1                                                     81,917         81,917    100.00
                     /dev/mapper/asmdata12p1                                                     81,917         81,917    100.00
********************                                                                     -------------- --------------
                                                                                                327,668        327,668

                                                                                         -------------- --------------
Grand Total:                                                                                    984,024        838,650



################################################## COMANDO PARA ADICIONAR OS DISCOS ##################################################


alter diskgroup DATA01 add disk '/dev/mapper/asmdata09p1' name DATA01_0016;
alter diskgroup DATA01 add disk '/dev/mapper/asmdata10p1' name DATA01_0017;
alter diskgroup DATA01 add disk '/dev/mapper/asmdata11p1' name DATA01_0018;
alter diskgroup DATA01 add disk '/dev/mapper/asmdata12p1' name DATA01_0019;




################################################## APOS EXECUCAO DOS COMANDOS ##################################################



Disk Group Name      Path                      File Name            Fail Group           File Size (MB) Used Size (MB) Pct. Used
-------------------- ------------------------- -------------------- -------------------- -------------- -------------- ---------
DATA01               /dev/mapper/asmdata01p1   DATA01_0008          DATA01_0008                  81,917         63,571     77.60
                     /dev/mapper/asmdata02p1   DATA01_0009          DATA01_0009                  81,917         63,566     77.60
                     /dev/mapper/asmdata03p1   DATA01_0010          DATA01_0010                  81,917         63,576     77.61
                     /dev/mapper/asmdata04p1   DATA01_0011          DATA01_0011                  81,917         63,572     77.61
                     /dev/mapper/asmdata05p1   DATA01_0012          DATA01_0012                  81,917         63,562     77.59
                     /dev/mapper/asmdata06p1   DATA01_0013          DATA01_0013                  82,937         64,692     78.00
                     /dev/mapper/asmdata07p1   DATA01_0014          DATA01_0014                  81,917         63,558     77.59
                     /dev/mapper/asmdata08p1   DATA01_0015          DATA01_0015                  81,917         63,577     77.61
                     /dev/mapper/asmdata09p1   DATA01_0016          DATA01_0016                  81,917            356       .43
                     /dev/mapper/asmdata10p1   DATA01_0017          DATA01_0017                  81,917            320       .39
                     /dev/mapper/asmdata11p1   DATA01_0018          DATA01_0018                  81,917            320       .39
                     /dev/mapper/asmdata12p1   DATA01_0019          DATA01_0019                  81,917            320       .39
********************                                                                     -------------- --------------
                                                                                                984,024        510,990

                                                                                         -------------- --------------
Grand Total:                                                                                    984,024        510,990







