cd sql
sqlplus system@BADOA/manager  @reinit_user BADOA_USER badoa_user
sqlplus system@BADOA/manager  @reinit_user BADOAES badoaes
sqlplus system@BADOA/manager  @reinit_user BADOAPM badoapm
sqlplus system@BADOA/manager  @reinit_user BADOAJOURNAL badoajournal
cd ..
#time imp userid=system/manager@BADOA fromuser=SYSTEM touser=BADOA_USER    file=./badoa_user_20090805.dmp statistics=none GRANTS=N log=ll.log
#time imp userid=system/manager@BADOA fromuser=SYSTEM touser=BADOAPM       file=./2009.12.14.BadoaPM.dmp statistics=none GRANTS=N log=ll.log
#time imp userid=system/manager@BADOA fromuser=SYSTEM touser=BADOAJOURNAL  file=./2009.12.14.BadoaJournal.dmp statistics=none GRANTS=N log=ll.log
#time imp userid=system/manager@BADOA fromuser=SYSTEM touser=BADOAES       file=./2009.12.14.BadoaES.dmp statistics=none GRANTS=N log=ll.log
