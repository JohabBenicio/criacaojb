rem  Criado em 06/09/2012
rem  
rem  Copiar backups do banco de dados DSV e SYSPEC.
rem  Apagar peças de backups com mais de 4 dias.
rem 
rem  Versao para windows

rem 
rem  Inicio
rem 

ECHO TIME IS %TIME%
ECHO DATE IS %DATE%

set hour=%time:~0,2%
set mn=%TIME:~3,2%
set sc=%TIME:~6,2%
set msec=%TIME:~9,2%
if %hour% equ 0: set hour=00
echo.
set day=%date:~0,2%
set mth=%DATE:~3,2%
set yr=%DATE:~6,4%
echo.
set datefolder=%day%-%mth%-%yr%_%hour%-%mn%-%sc%

echo %datefolder%


set ORACLE_SID=SYSPEC
c:
cd C:\oracle\product\10.2.0\admin\SCRIPTS\copiabkp

del exec\exec_tcp.cmd

sqlplus / as sysdba @sql\jbcp_bkp_tcp.sql > exec\exec_tcp.cmd

exec\exec_dsv_syspec.cmd > log\exec_dsv_syspec_%datefolder%.log


exit

rem  Fim


