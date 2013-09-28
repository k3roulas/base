awk 'BEGIN{RS="";FS="<|>"}
/Jour Date/{
 for(i=1;i<=NF;i++){
    #if($i ~ /Jour Date/){
        #gsub(/<.*Jour Date>/,"",$i)
    #}    
    j=i+2
    if ($i ~ /Jour Date/ )
      print $i
 } 
}' fichier
