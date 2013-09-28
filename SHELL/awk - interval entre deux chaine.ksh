awk -F"<|>" ' 
/<span/,/\/span/ { print }
{ 
  nom=""
  flag="off"
  sub(/<span.*">/,"", $0)
  #print $0
  for (i=1;i<NF;i++)  {

    if ($i ~ /^a class/) flag="on"
    if ($i ~ /\/a/)      flag="off"

    #if (flag == "on") print $i

  }

}' fic

