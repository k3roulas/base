
#Il faut alors penser à jouer avec le « Internal Field Separator » – IFS – 
#pour indiquer à BASH quel(s) caractère(s) considérer comme saut de ligne.
#Par défaut, on trouve le saut de ligne « \n », mais aussi la tabulation (« \t ») et l’espace

IFS=$'\n'

# or use read :
cat tt | while read ligne ; do echo $ligne ; done

#or in a script
while read ligne ; do echo $ligne ; done; < tt
