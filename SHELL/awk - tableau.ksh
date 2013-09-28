awk -F";" ' 
  BEGIN { 
  }

  NR != 1 && $0 != "<EOF>" {
    pma[NR-1]=$10
    tendance[NR-1]=$11
  }


  END { 
     printf("WEBKRONIK_PMA;A;A;0_12;")
     for ( i = 1; i <= 24; i++ ) {
       for ( j = 0; j <6 ; j++ ) {
          printf("%s;", pma[i]);
       }
     }
     printf("\nWEBKRONIK_PMA;A;A;12_24;")
     for ( i = 25; i <= 48; i++ ) {
       for ( j = 0; j <6 ; j++ ) {
          printf("%s;", pma[i]);
       }
     }
     printf("\nWEBKRONIK_TENDANCE;A;A;0_12;")
     for ( i = 1; i <= 24; i++ ) {
       for ( j = 0; j <6 ; j++ ) {
          printf("%s;", tendance[i]);
       }
     }
     printf("\nWEBKRONIK_TENDANCE;A;A;12_24;")
     for ( i = 25; i <= 48; i++ ) {
       for ( j = 0; j <6 ; j++ ) {
          printf("%s;", tendance[i]);
       }
     }
  }
' $1

