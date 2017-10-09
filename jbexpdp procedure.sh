

cat <<EOF>bkp_procedure.par
directory=MIGRA
schemas=PCS_PROD
dumpfile=expdp_procedure_ticket7310783.dmp
logfile=expdp_procedure_ticket7310783.log
include=PROCEDURE:"in ('COL_EDIT_COLLECTS','PCS_COL_GETCASHSESSIONBY','PCS_COL_GETCASHSESSIONS','PCS_COL_GETCHSESSIONSUMMARY','PCS_COL_GETCOLLECTBYID','PCS_COL_GETCOLLECTPOINT','PCS_COL_GETCOLLECTS','PCS_COL_GETCOLLECTSTATISTICS','PCS_COL_GETCOLLECTTRANMT','PCS_COL_GETCOLMONITOR','PCS_COL_GETPAGEDCOLLECTS','PCS_COL_INS_COLLECTTRANMT')"
EOF


impdp \'/ as sysdba \' sqlfile=procedures.sql directory=MIGRA dumpfile=expdp_procedure_ticket7310783.dmp


expdp \'/ as sysdba\'  parfile=bkp_procedure.par



cd  /backup/VSBLSPT/logico











