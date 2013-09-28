cd sql
sqlplus system@SCHEMA/manager  @reinit_user AGAPE agape1234
cd ..
imp userid=system/manager@SCHEMA fromuser=NAME touser=NAME file=./imp.dmp statistics=none GRANTS=N log=ll.log
