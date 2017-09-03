
############################################################################################################
# Prod GRORAP
############################################################################################################
1) Validar a inexistencia da tabela a ser criada. (DATABASE)
desc system.STATS_DB_TEOR_P

2) Criar a tabela para receber as estatisticas. (DATABASE)
execute dbms_stats.create_stat_table (ownname => 'SYSTEM', stattab => 'STATS_DB_TEOR_P');

3) Exportar as estatisticas para a tabela criada. (DATABASE)
execute dbms_stats.export_database_stats (statown => 'SYSTEM', stattab => 'STATS_DB_TEOR_P');

4) Backup das estatisticas que se encontra na tabela criada. (S.O.)
expdp \'/ as sysdba \' directory=EXPDP_FULL dumpfile=expdp_18052016_stats_db_teor_p.dmp logfile=expdp_18052016_stats_db_teor_p.log tables=SYSTEM.STATS_DB_TEOR_P

5) Apagar a tabela criada no passo 2. (DATABASE)
drop table system.STATS_DB_TEOR_P;



############################################################################################################
# Desenv GRORAD
############################################################################################################

6) Validar a inexistencia da tabela a ser criada. (DATABASE)
desc system.STATS_DB_TEOR_D

7) Criar a tabela para receber as estatisticas. (DATABASE)
execute dbms_stats.create_stat_table (ownname => 'SYSTEM', stattab => 'STATS_DB_TEOR_D');

8) Exportar as estatisticas para a tabela criada. (DATABASE)
execute dbms_stats.export_database_stats (statown => 'SYSTEM', stattab => 'STATS_DB_TEOR_D');

9) Backup das estatisticas que se encontra na tabela criada. (S.O.)
expdp \'/ as sysdba \' directory=IMPDP dumpfile=expdp_18052016_stats_db_teor_d.dmp logfile=expdp_18052016_stats_db_teor_d.log tables=SYSTEM.STATS_DB_TEOR_D

10) Importar a tabela que contem as estatisticas da base de produção na base de desenvolvimento. (S.O.)
impdp \'/ as sysdba \' directory=IMPDP dumpfile=expdp_18052016_stats_db_teor_p.dmp logfile=impdp_18052016_stats_db_teor_p.log tables=SYSTEM.STATS_DB_TEOR_P

11) Importar as estatisticas na base de desenvolvimento. (DATABASE)
execute dbms_stats.import_database_stats (statown => 'SYSTEM', stattab => 'STATS_DB_TEOR_P');







