

delete force archivelog all backed up 1 times to device type disk;


du KCOR/ARCHIVELOG
du PEDAGIO/ARCHIVELOG
du SIRIUSJM/ARCHIVELOG
du SMDB/ARCHIVELOG




mkdir +DGDATAC/SIRIUSJM
mkdir +DGDATAC/SIRIUSJM/TEMPFILE


      File          Max
  size(MB)     size(MB) Auto Tablespace       Status     File# File
---------- ------------ ---- ---------------- ---------- ----- -----------------------------------------------
     8,000        8,000 YES  TEMP             ONLINE         1 +DGDATA/siriusjm/tempfile/temp.585.900671505
    30,720       30,720 YES  TEMP             ONLINE         2 +DGDATA/siriusjm/tempfile/temp.996.914090323
    32,767       32,767 YES  TEMP             ONLINE         3 +DGDATA/siriusjm/tempfile/temp.1496.914148819
    32,767       32,767 YES  TEMP             ONLINE         4 +DGDATA/siriusjm/tempfile/temp.859.914148831





alter database tempfile 3 offline;

cp +DGDATA/siriusjm/tempfile/temp.1496.914148819 +DGDATAC/SIRIUSJM/TEMPFILE/temp_03.dbf


alter database tempfile 4 offline;

cp +DGDATA/siriusjm/tempfile/temp.859.914148831 +DGDATAC/SIRIUSJM/TEMPFILE/temp_04.dbf


alter database rename file '+DGDATA/siriusjm/tempfile/temp.996.914090323' to '+DGDATAC/SIRIUSJM/TEMPFILE/temp_02.dbf';
alter database tempfile 2 online;

alter database rename file '+DGDATA/siriusjm/tempfile/temp.1496.914148819' to '+DGDATAC/SIRIUSJM/TEMPFILE/temp_03.dbf';
alter database tempfile 3 online;

alter database rename file '+DGDATA/siriusjm/tempfile/temp.859.914148831' to '+DGDATAC/SIRIUSJM/TEMPFILE/temp_04.dbf';
alter database tempfile 4 online;















col kbytes           format 9g999g990  heading File|size(MB)
col kmaxsize         format 999g999g990  heading Max|size(MB)
col kautoextensible  format a4         heading Auto
col ktablespace_name format a16        heading Tablespace
col kstatus          format a10        heading Status
col kfile_id         format 990        heading File#
col kfile_name       format a100        heading File
set lines 200

select trunc(bytes/1024/1024) kbytes,
       trunc(maxbytes/1024/1024) kmaxsize,
       autoextensible kautoextensible,
       tablespace_name ktablespace_name,
       status kstatus,
       file_id kfile_id,
       file_name kfile_name
from dba_temp_files
order by tablespace_name, file_name;





Disk Group Name: +DGDATA
Total Size (MB): 3,145,848
Used Size (MB): 2,975,954
Free Size (MB): 169,894
Pct. Used: 94.6
Pct. Free: 5.4



