#!/bin/sh
LISTE_BASE=liste_fichier_from_base.txt
LISTE_REP=liste_fichier_from_rep.txt



LADATE=$1

if [ -z "$1" ]; then
   echo 
   echo usage : $0 YYYYMMDD
   echo 
   exit
fi

echo "Traitement de la date du $LADATE"


if [ -e tmp.fic ]; then rm tmp.fic; fi
if [ -e $LISTE_BASE ]; then rm $LISTE_BASE; fi
if [ -e $LISTE_REP ]; then rm $LISTE_REP; fi

sqlplus user/mdp@host @cmd.sql $1

sed -n "5,$ p" $LISTE_BASE > tmp.fic 
sort -u tmp.fic -o $LISTE_BASE
rm tmp.fic
dos2unix.exe $LISTE_BASE

#recherche des fichiers 
function GET_FILE 
{
 echo "Traitement du repertoire $1 ..."
 time ls -l $1 --time-style=+%Y%m%d  | awk ' $5 != 6 && $6 ~ /'$LADATE'/ { print $6"\t"$7} ' | cut -f2 >> $2
 echo "Traitement termine"
}

# fichier CT
GET_FILE //path_file tmp.fic

grep "5min" tmp.fic >> $LISTE_REP
grep "D_" tmp.fic >> $LISTE_REP
grep "S_" tmp.fic >> $LISTE_REP
rm tmp.fic

sort -u $LISTE_REP -o $LISTE_REP

diff $LISTE_REP $LISTE_BASE | grep "<" > "$LADATE.txt"
