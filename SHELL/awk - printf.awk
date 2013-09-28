cat file.csv | awk -F";" ' { 
  for (i=1; i<NF; ++i) {
    if ( i == 8 )  {
      printf "%s;%s;%s;%s;", $8,$9,$10,$11
    } if (i != 8 && i != 9 ) {
      printf "%s;", $i
    };
  };
  print $(NF)
    
'} > file_res.csv
