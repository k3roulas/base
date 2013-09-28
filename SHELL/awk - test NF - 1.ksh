awk 'BEGIN{RS="";FS="<|>"}
/Previsionniste/{
 for(i=1;i<=NF;i++){
    #if($i ~ /Previsionniste/){
        #gsub(/<.*Previsionniste>/,"",$i)
    #}    
    j=i+2
    if ($i == "Previsionniste" && $j == "/Previsionniste")
      print $(i+1)
 } 
}' fichier
