

site=163.104.24.162
login=emmafluxREC
mdp=emmafluxREC


function putFtp
{
fichier=$1
ftp -in $site << LIST
user $login $mdp
cd /_prog_pas_reduit/backoffice
bin
put $fichier
quit
LIST
}

function getFtp
{
fichier=$1
ftp -in $site << LIST
user $login $mdp
cd /_prog_pas_reduit/backoffice
bin
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
get $fichier
quit
LIST
}


putFtp PROG_REDUIT_G_20070102_1001_P_20070101.CSV

while [ "1" ]; do 
getFtp PROG_REDUIT_G_20070102_1001_P_20070101.CSV
echo "fait"
done
