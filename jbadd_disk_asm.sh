
## Se caso estiver trabalhando em ambiente virtualizado e o disco não aparecer, realizar um scan:

Scanning SCSI DISKS in Redhat Linux

1. Listar os discos existentes

fdisk -l | grep 'Disk /'
Disk /dev/sda: 53.6 GB, 53687091200 bytes
Disk /dev/sdb: 1073 MB, 1073741824 bytes

---------------------------------------------------------------------------------------------------------------------

2. Scan nos discos

for i in `ls -1 /sys/class/scsi_host`; do
echo "- - -" > /sys/class/scsi_host/${i}/scan
done


---------------------------------------------------------------------------------------------------------------------

4. Verifique os novos discos

[root@jhbmaster01 ~]#  fdisk -l | grep 'Disk /'
Disk /dev/sda: 53.6 GB, 53687091200 bytes
Disk /dev/sdb: 1073 MB, 1073741824 bytes
Disk /dev/sdd: 1073 MB, 1073741824 bytes

---------------------------------------------------------------------------------------------------------------------

## verificar se o disco disponibilizado esta sendo usado

[root@jhbmaster01 ~]# blkid
/dev/mapper/jhbmaster01-swap03: TYPE="swap"
/dev/mapper/jhbmaster01-swap02: TYPE="swap"
/dev/mapper/jhbmaster01-swap01: TYPE="swap"
/dev/mapper/jhbmaster01-tmp: UUID="c7f99169-51fc-4144-a89e-c3a899bd386f" TYPE="ext3"
/dev/mapper/jhbmaster01-oracle: UUID="0dedc8b2-651f-4c5b-a7e8-9273e10dafd3" TYPE="ext3"
/dev/mapper/jhbmaster01-root: UUID="41ae194a-e53b-4c28-b448-d9b3d1722b25" TYPE="ext3"
/dev/sda1: LABEL="/boot" UUID="6e84d6e0-b6de-4538-976c-a3d79e80a2bf" TYPE="ext3" SEC_TYPE="ext2"
/dev/hdc: LABEL="VMware Tools" TYPE="iso9660"
/dev/jhbmaster01/root: UUID="41ae194a-e53b-4c28-b448-d9b3d1722b25" TYPE="ext3"
/dev/jhbmaster01/swap01: TYPE="swap"
/dev/jhbmaster01/swap02: TYPE="swap"
/dev/jhbmaster01/swap03: TYPE="swap"
/dev/cdrom: LABEL="DISC" TYPE="iso9660"
/dev/sdc1: LABEL="SDC1" TYPE="oracleasm"
/dev/sdb1: LABEL="SDB1" TYPE="oracleasm"


---------------------------------------------------------------------------------------------------------------------

## No caso o disco foi apresentado mas nao foi formatado, temos que formatar:

[root@jhbmaster01 ~]# fdisk /dev/sdd
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel. Changes will remain in memory only,
until you decide to write them. After that, of course, the previous
content won't be recoverable.


The number of cylinders for this disk is set to 6527.
There is nothing wrong with that, but this is larger than 1024,
and could in certain setups cause problems with:
1) software that runs at boot time (e.g., old versions of LILO)
2) booting and partitioning software from other OSs
   (e.g., DOS FDISK, OS/2 FDISK)
Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

Command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> P (primary partition )
Partition number (1-4): 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>> PARTICAO 1
First cylinder (1-6527, default 1):
Using default value 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DO PRIMEIRO BLOCO
Last cylinder or +size or +sizeM or +sizeK (1-6527, default 6527):
Using default value 6527 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>> AO ULTIMO BLOCO

Command (m for help): w     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>    GRAVAR
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@jhbmaster01 ~]#

---------------------------------------------------------------------------------------------------------------------

## tem que ficar desta forma apos a formatação;

[root@jhbmaster01 ~]# fdisk -l /dev/sdd

Disk /dev/sdd: 1073 MB, 1073741824 bytes
255 heads, 63 sectors/track, 130 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1         130     1044193+  83  Linux


---------------------------------------------------------------------------------------------------------------------

# lista os discos do ASM

[root@jhbmaster01 ~]# oracleasm listdisks
DISK1
DISK2
DISK3
DISK4


---------------------------------------------------------------------------------------------------------------------

# Criar o disco para o ASM

oracleasm createdisk DISK5 /dev/sdd1  
Writing disk header: done
Instantiating disk: done
You have new mail in /var/spool/mail/root

---------------------------------------------------------------------------------------------------------------------

# lista os discos do ASM novamente para confirma

[root@jhbmaster01 ~]# oracleasm listdisks
DISK1
DISK2
DISK3
DISK4
DISK5




#######################################################################################################################
##                USUARIO ORACLE
#######################################################################################################################


Se você esta no ambiente Oracle 11g você deve conectar com sysasm, segue um exemplo:   sqlplus / as sysasm
[oracle@jhbmaster01 ~]$ . oraenv
ORACLE_SID = [jhbprod] ? +ASM

[oracle@jhbmaster01 ~]$ sqlplus / as sysasm

Se você esta no ambiente Oracle 10g você deve conectar com sysdba, segue um exemplo:   sqlplus / as sysdba

[oracle@jhbmaster01 ~]$ . oraenv
ORACLE_SID = [jhbprod] ? +ASM

[oracle@jhbmaster01 ~]$ sqlplus / as sysdba


---------------------------------------------------------------------------------------------------------------------


# Executar o Script

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20           HEAD 'Disk Group Name'
COLUMN disk_file_path         FORMAT a27           HEAD 'Path'
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
 -- , ROUND((1- (b.free_mb / b.total_mb))*100, 2)      pct_used
FROM
    v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number)
ORDER BY
    a.name
/


---------------------------------------------------------------------------------------------------------------------

#######################################################################################################################
##################################################### RESULTADO #######################################################
#######################################################################################################################
# O Disco Apontado como CANDIDATE e o Disco que Criamos acima e ainda nao foi entregue ao DISKGROUP




Disk Group Name      Path              File Name            Fail Group           File Size (MB) Used Size (MB)
-------------------- ----------------- -------------------- -------------------- -------------- --------------
DGDATA               ORCL:DISK1        DISK1                DISK1                        46,626         21,460
                     ORCL:DISK3        DISK3                DISK3                        46,641         21,449
                     ORCL:DISK2        DISK2                DISK2                        46,626         21,384
                     ORCL:DISK4        DISK4                DISK4                        46,626         21,384
********************                                                             -------------- --------------

[CANDIDATE]          ORCL:DISK5                                                           1,024          1,024
********************                                                             -------------- --------------
                                                                                          1,024          1,024



#
# Entregando o DISK5 para o ASM
#

SYS> alter diskgroup DGDATA add disk 'ORCL:DISK5';

Diskgroup altered.


---------------------------------------------------------------------------------------------------------------------
#######################################################################################################################
####    OU
#######################################################################################################################


Disk Group Name      Path                        File Name            Fail Group           File Size (MB) Used Size (MB)
-------------------- --------------------------- -------------------- -------------------- -------------- --------------
DGDATA               /dev/oracleasm/disks/DISK4  DGDATA_0003          DGDATA_0003                   1,019            873
                     /dev/oracleasm/disks/DISK1  DGDATA_0000          DGDATA_0000                   1,019            877
                     /dev/oracleasm/disks/DISK3  DGDATA_0002          DGDATA_0002                   1,019            878
                     /dev/oracleasm/disks/DISK2  DGDATA_0001          DGDATA_0001                   1,019            882
********************                                                                       -------------- --------------
                                                                                                    4,076          3,510

[CANDIDATE]          /dev/oracleasm/disks/DISK5                                                     1,024          1,024
                                                                                           -------------- --------------



#
# Entregando o DISK4 para o ASM
#

SQL> alter diskgroup DGDATA add disk '/dev/oracleasm/disks/DISK5' name DISK6;

Diskgroup altered.

---------------------------------------------------------------------------------------------------------------------


