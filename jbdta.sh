

lsb_release -a

echo -e "\n"
uname -r
echo -e "\n"


VAL=$(ps -ef | grep smon  | grep -i asm | grep -v grep | wc -l)

if [ "$VAL" -eq "1" ]; then
	export ORACLE_GRID_HOME=$(ps -fe | grep "ocssd.bin" | grep -v grep | awk '{print $NF}' | sed 's/\/bin\/ocssd.bin//' | sed '/ocssd.bin/d')
fi

echo -e "\n"

opatch lsinventory -oh $ORACLE_HOME

echo -e "\n"

opatch lsinventory -oh $ORACLE_GRID_HOME
echo -e "\n"


dmidecode


export JBSOQ=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
export JBCORE=$(cat /proc/cpuinfo | grep "core id" | sort | uniq | wc -l)
export JBCPU=$(cat /proc/cpuinfo| grep processor | sed 's/.*:\(.*\)$/\1/' | sort | wc -l)

echo -e "\n" ;echo "QTD de SOQUETES: $JBSOQ"; echo "QTD de CORE: $JBCORE"; echo "Processor (CPU's): $JBCPU"; echo -e "\n" 



fdisk -l

echo -e "\n"

inconfig

echo -e "\n"

hostname 

echo -e "\n"

cat /etc/sysconfig/network-scripts/ifcfg-eth0

echo -e "\n"



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


echo -e "\n"


cat /etc/hosts

echo -e "\n"

df -hTP | column -t
echo -e "\n"

cat /etc/passwd
echo -e "\n"

cat /etc/group
echo -e "\n"

cat /etc/sysctl.conf
echo -e "\n"

cat /etc/sysconfig/network-scripts/ifcfg-eth0
echo -e "\n"



set pages 9999 lines 200
COL KTABLESPACE   FOR A27      HEADING 'Tablespace'
COL KTBS_SIZE     FOR 9,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL KTBS_EM_USO   FOR 9,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL KTBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL KFREE_SPACE   FOR 9,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL KSPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL KPERC         FOR 990      HEADING '%|Ocupacao'          JUSTIFY RIGHT

break on report

compute sum label Total: of ktbs_size    on report
compute sum              of ktbs_em_uso  on report
compute sum              of ktbs_maxsize on report
compute sum              of kfree_space  on report
compute sum              of kspace       on report

select t.tablespace_name ktablespace,
       substr(t.contents, 1, 1) tipo,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) ktbs_em_uso,
       trunc(d.tbs_size/1024/1024) ktbs_size,
       trunc(d.tbs_maxsize/1024/1024) ktbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) kfree_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) kspace,
       decode(d.tbs_maxsize, 0, 0, trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize)) kperc
from
  ( select SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s,
  dba_tablespaces t
where t.tablespace_name = d.tablespace(+) and
      t.tablespace_name = s.tablespace(+)
order by 8;



echo -e "\n"
















