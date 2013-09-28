awk -F"<|>" ' 
{ 
  nom=""
  flag="off"
  nb_ahref=0

  gsub(/<span class="icon">/,"", $0)
  gsub(/<\/span>/,"", $0)

  for (i=1;i<NF;i++)  {

    if ($i ~ /^a class/) flag="on"
    if ($i ~ /\/a/)      flag="off"

    if (flag == "on") print $i

  }

}' fic
