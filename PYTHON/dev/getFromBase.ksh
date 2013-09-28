# script de lancement du calcul des bilans

BASE=basename
USER=user
MDP=mdp
DEST=directory


function getFromBase {
  echo "set head off;
set feed off;
set trimspool on;
set linesize 1000; 
set pagesize 0;
set echo off;
set termout off;
spool $2;
$1
spool off;
exit;" > req.sql
sqlplus  $USER/$MDP@$BASE @req
}

echo $base
# extraction de la base de données des edp
getFromBase  "select NOM_EDP 
|| ';' || to_char(DATE_DEBUT_VALIDITE, 'dd/mm/yyyy')
|| ';' || to_char(DATE_FIN_VALIDITE, 'dd/mm/yyyy')
from table;
" $DEST/edp.csv