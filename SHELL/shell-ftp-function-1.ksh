

site=192.168.0.2
login=login
mdp=mdp


function transfertFtp
{
fichier=$1
ftp -in $site << LIST
user $login $mdp
cd /_prog_pas_reduit/backoffice
bin
put $fichier
LIST
}

#tranfertFtp "unptittest"

while [ "1" ]; do 
heure=`date "+%H%M"`
fic=20080101_${heure}_P_20080101.CSV
echo $fic
cat 20080101_1001_P_20080101.CSV > $fic
transfertFtp $fic
sleep 61
done
