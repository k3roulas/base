range 
awk -F";" ' { for (i=1; i<NF; ++i) printf "%s;", $i; print $(NF) }'