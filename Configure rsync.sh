rsync -ave "ssh" --exclude="full*" /u02/backup/producao/fisico/ oracle@10.0.10.217:/u02/backup/producao/fisico/



rsync -ave "ssh" --exclude="full*" --include="arch*" /backup/oracle/mat1/fisico oracle@172.20.0.29:/u02/backup/mat1/fisico/


