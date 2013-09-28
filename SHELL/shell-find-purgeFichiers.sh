#!/usr/bin/ksh
##########################################################################
# SCRIPT DE SUPPRESSION DES FICHIERS DE LOGS, BILANS ET BADO outils PA/PM 
##########################################################################
# CREE LE  : 11/08/2009
# PAR : S.RIGAUX (ATOS ORIGIN)
# VERSION 1.0
##########################################################################


ChercheEtSupprime()
{
	if [ $# -ne 3 ]
	then
		echo "Il faut 3 parametres : repertoire pattern retention"
		return 1
	fi


	dir="$1"
	pattern="$2"
	retention=$3

	# test des paramètres
	if [ ! -d ${dir} ]
	then
		echo "Le repertoire de recherche ${dir} n'existe pas !!!"
		return 2
	fi 

	if [ "${pattern}" == "" ]
	then
		echo "Le parametre pattern ${pattern} doit etre alimente !!!"
		return 3
	fi

	if [[ ${retention} != +([0-9]) ]]
	then 
		echo "La retention ${retention} n'est pas un entier" 
		return 4
	fi 
	echo "Suppression dans ${dir} des fichiers suivant le modele ${pattern} de plus de ${retention} jour(s)"
	find "${dir}" -type f -name "${pattern}" -xdev -mtime +"$retention" -exec rm {} \;
}

getDate()
{
	date +"%Y-%m-%d %H:%M:%S"
}

# Date
echo "------------------------------------------------------"
echo `getDate`" : Lancement de la purge"
echo "------------------------------------------------------"


# chargement du profil
. ~/.profile

# 3 mois vaut au maximum 31 + 30 + 31 jours soit 92 jours
ChercheEtSupprime /home/badoa/log \* 92
ChercheEtSupprime /home/badoa/fichiers_bilan \* 92
ChercheEtSupprime /home/badoa/BADOA_OUTILS/Prog_Reduit \* 31
ChercheEtSupprime /home/badoa/BADOA_OUTILS/DCCS \* 31
ChercheEtSupprime /home/badoa/BADOA_OUTILS/DCRD \* 31

echo "------------------------------------------------------"
echo `getDate`" : Fin de la purge"
echo "------------------------------------------------------"




