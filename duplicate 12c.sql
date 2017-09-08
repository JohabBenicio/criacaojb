DUPLICATE DATABASE TO cdb2 PLUGGABLE DATABASE pdb1, pdb2
  FROM ACTIVE DATABASE
  SPFILE
    parameter_value_convert ('cdb1','cdb2')
    set db_file_name_convert='/u01/app/oracle/oradata/cdb1/','/u01/app/oracle/oradata/cdb2/'
    set log_file_name_convert='/u01/app/oracle/oradata/cdb1/','/u01/app/oracle/oradata/cdb2/'
    set audit_file_dest='/u01/app/oracle/admin/cdb2/adump'
    set core_dump_dest='/u01/app/oracle/admin/cdb2/cdump'
    set control_files='/u01/app/oracle/oradata/cdb2/control01.ctl','/u01/app/oracle/oradata/cdb2/control02.ctl','/u01/app/oracle/oradata/cdb2/control03.ctl'
    set db_name='cdb2'
  NOFILENAMECHECK;




run{
  allocate channel c1 device type disk;
  allocate auxiliary channel ac1 device type disk;
    duplicate database cdbrac1 to orcl pluggable database TESTE_PDB from active database;  
}




RMAN> connect target "sys/*****@prmcdb as sysdba";
 
connected to target database: PRMCDB (DBID=2508276746)
 
RMAN> connect auxiliary "sys/******@dupcdb as sysdba";
 
connected to auxiliary database: DUPCDB (not mounted)
 

 duplicate database to orcl pluggable database TESTE_PDB from active database;  


 SID_LIST_LISTENER =
  (SID_LIST =
    )
    (SID_DESC =
      (SID_NAME = orcl)
      (ORACLE_HOME = /u01/app/oracle/product/12.2.0.1/db_1)
      (GLOBAL_DBNAME = orcl)
    )
  )


