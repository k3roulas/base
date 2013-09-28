awk -F";" ' 

function abs(a) { if(a<0) a=-a; return a; } 

  BEGIN { 
    res = 0;
    rte = 0;
    re = 0;
    tot = 0;
    cout_rte =0;
    cout_re =0;
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
  $3 == "OH" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { oh_0_12[i]=$(i); } }
  $3 == "OH" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { oh_12_24[i]=$(i); } }
  $3 == "OB" && $4 == "0_12"  { for ( i = 5 ; i < 149 ; i++ ) { ob_0_12[i]=$(i); } }
  $3 == "OB" && $4 == "12_24" { for ( i = 5 ; i < 149 ; i++ ) { ob_12_24[i]=$(i); } }

  $3 == "COMMENTAIRE"  && $4 == "12_24"{ 

    vol_edp = 0;
    vol_edp_re = 0;
    vol_edp_rte = 0;
    cout_edp_re = 0;
    cout_edp_rte = 0;

     for ( i = 5 ; i < 149 ; i++ ) {

        tot = tot +  abs((pm_0_12[i] - pa_0_12[i]) / 12);

        if ( cause_0_12[i] == "SSY" ) {
          vol = (pm_0_12[i] - pa_0_12[i]) / 12;
          res = res + abs(vol);
          vol_edp = vol_edp + abs(vol);
          if ( tendance_0_12[i] == "2") { // hausse
             rte = rte + abs(vol) ;
             vol_edp_rte = vol_edp_rte + abs(vol);
             if (vol > 0) {
                cout = (oh_0_12[i] - pma_0_12[i]) * abs(vol);
                cout_edp_rte = cout_edp_rte + cout;
                print i" cout : "cout;
             } else {
                cout = (pma_0_12[i] - ob_0_12[i]) * abs(vol);
                cout_edp_rte = cout_edp_rte + cout;
                print i" cout : "cout;
             }
          } else if (tendance_0_12[i] == "1") {
             re = re + abs(vol) ;
             vol_edp_re = vol_edp_re + abs(vol);
             if (vol > 0) {
                cout = (oh_0_12[i] - pma_0_12[i]) * abs(vol);
                cout_edp_re = cout_edp_re + cout;
                print i" cout : "cout;
             } else {
                cout = (pma_0_12[i] - ob_0_12[i]) * abs(vol);
                cout_edp_re = cout_edp_re + cout;
                print i" cout : "cout;
             }
          }
        }

        tot = tot +   abs((pm_12_24[i] - pa_12_24[i]) / 12);

        if ( cause_12_24[i] == "SSY" ) {
          vol = (pm_12_24[i] - pa_12_24[i]) / 12;
          res = res + abs(vol);
          vol_edp = vol_edp + abs(vol);
          if ( tendance_12_24[i] == "2") { // hausse
             rte = rte + abs(vol);
             vol_edp_rte = vol_edp_rte + abs(vol);
             if (vol > 0) {
                cout = (oh_12_24[i] - pma_12_24[i]) * abs(vol);
                cout_edp_rte = cout_edp_rte + cout;
                print i" cout : "cout;
             } else {
                cout = (pma_12_24[i] - ob_12_24[i]) * abs(vol);
                cout_edp_rte = cout_edp_rte + cout;
                print i" cout : "cout;
             }
          } else if (tendance_12_24[i] == "1") {
             re = re + abs(vol);
             vol_edp_re = vol_edp_re + abs(vol);
             if (vol > 0) {
                cout = (oh_12_24[i] - pma_12_24[i]) * abs(vol);
                cout_edp_re = cout_edp_re + cout;
                print i" cout : "cout;
             } else {
                cout = (pma_12_24[i] - ob_12_24[i]) * abs(vol);
                cout_edp_re = cout_edp_re + cout;
                print i" cout : "cout;
             }
          }
        }

     }

     cout_rte = cout_rte + cout_edp_rte;
     cout_re = cout_re + cout_edp_re;

     if (vol_edp != 0) {
        print ($1";"$2" volume ssy     : "vol_edp);
        print ($1";"$2" volume ssy re  : "vol_edp_re);
        print ($1";"$2" volume ssy rte : "vol_edp_rte);
        print ($1";"$2" cout rte       : "cout_edp_rte);
        print ($1";"$2" cout re        : "cout_edp_re);
        print ""
     }

  }

  END { 
    print "total ssy  : " res
    print "rte ssy : " rte
    print "re ssy : " re
    print "rte cout : " cout_rte
    print "re cout : " cout_re
    print ""
    print "total : " tot
  }
' prog_pln.csv

