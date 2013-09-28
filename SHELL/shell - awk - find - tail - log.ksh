#!/bin/ksh
NB_LIGNE_MAX=3
NOM_FICHIER_LOG=log

NB_LIGNE=`awk 'END { print NR }' $NOM_FICHIER_LOG`

if ((NB_LIGNE>NB_LIGNE_MAX)); then
	tail -$NB_LIGNE_MAX log > tt.tmp
        mv tt.tmp $NOM_FICHIER_LOG &2>/dev/null
fi


REP=/REP_TMP
NB_JOUR=3

echo "execution le "`date -u +%Y/%m/%d" "%T` 
echo "Suppression de : " 
find $REP -mtime $NB_JOUR  
