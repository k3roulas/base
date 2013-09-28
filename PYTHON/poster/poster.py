import string
import urllib
import httplib  
import sys  
import sys
sys.path.append('../lib')
from eai import *

###################
# debut du script
###################

if len(sys.argv) != 2:
  print "Usage : " + sys.argv[0] + " fichier"
  sys.exit(1)
nom_fichier = sys.argv[1]

f = open(nom_fichier, 'r')
xml = f.read()
f.close()

PostEai('163.104.211.157:7002', '/badoa/SoumissionCTCUOJMoins1Producteur', xml)
print "Trame Envoyee"
#PostEai('163.104.30.195:7101', '/badoa/SoumissionCTCUOJMoins1Producteur', xml)
