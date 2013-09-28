awk -F";" ' 

function abs(a) { if(a<0) a=-a; return a; } 

  BEGIN { 
    res = 0;
    rte = 0;
    re = 0;
    tot = 0;
  }

  $1 == "WEBKRONIK_PMA" && $4 == "0_12"   { for ( i = 5 ; i < 149 ; i++ ) { pma_0_12[i]=$(i);  } }
  $1 == "WEBKRONIK_PMA" && $4 == "12_24"  { for ( i = 5 ; i < 149 ; i++ ) { pma_12_24[i]=$(i); } }
  $1 == "WEBKRONIK_TENDANCE" && $4 == "0_12"   { for ( i = 5 ; i < 149 ; i++ ) { tendance_0_12[i]=$(i);  } }
  $1 == "WEBKRONIK_TENDANCE" && $4 == "12_24"  { for ( i = 5 ; i < 149 ; i++ ) { tendance_12_24[i]=$(i); } }
  $3 == "PA" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { pa_0_12[i]=$(i);  } }
  $3 == "PA" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { pa_12_24[i]=$(i); } }
  $3 == "PM" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { pm_0_12[i]=$(i);  } }
  $3 == "PM" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { pm_12_24[i]=$(i); } }
  $3 == "CAUSE" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { cause_0_12[i]=$(i);  } }
  $3 == "CAUSE" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { cause_12_24[i]=$(i); } }
  $3 == "COMMENTAIRE" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { commentaire_0_12[i]=$(i);  } }
  $3 == "COMMENTAIRE" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { commentaire_12_24[i]=$(i); } }

  $3 == "COMMENTAIRE"  && $4 == "12_24"{ 

    vol_edp = 0;
    vol_edp_re = 0;
    vol_edp_rte = 0;

     for ( i = 5 ; i < 149 ; i++ ) {

        tot = tot +  abs((pm_0_12[i] - pa_0_12[i]) / 12);

        if ( cause_0_12[i] == "SSY" ) {
          vol = abs((pm_0_12[i] - pa_0_12[i]) / 12);
          res = res + vol;
          vol_edp = vol_edp + vol;
          if ( tendance_0_12[i] == "2") { // hausse
             rte = rte + vol ;
             vol_edp_rte = vol_edp_rte + vol;
          } else if (tendance_0_12[i] == "1") {
             re = re + vol ;
             vol_edp_re = vol_edp_re + vol;
          }
        }

        tot = tot +   abs((pm_12_24[i] - pa_12_24[i]) / 12);

        if ( cause_12_24[i] == "SSY" ) {
          vol = abs((pm_12_24[i] - pa_12_24[i]) / 12);
          res = res + vol;
          vol_edp = vol_edp + vol;
          if ( tendance_12_24[i] == "2") { // hausse
             rte = rte + vol ;
             vol_edp_rte = vol_edp_rte + vol;
          } else if (tendance_12_24[i] == "1") {
             re = re + vol ;
             vol_edp_re = vol_edp_re + vol;
          }
        }

     }

     if (vol_edp != 0) {
        print ($1";"$2" volume ssy     : "vol_edp);
        print ($1";"$2" volume ssy re  : "vol_edp_re);
        print ($1";"$2" volume ssy rte  : "vol_edp_rte);
        print ""
     }

  }

  END { 
    print "total ssy  : " res
    print "rte ssy : " rte
    print "re ssy : " re
    print ""
    print "total : " tot
  }
' prog_pln.csv

