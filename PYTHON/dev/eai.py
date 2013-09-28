import httplib
import socket
import sys


#################################
# ParseurLigne
#################################

class ParseurLigne:
  def __init__(self, ligne):
    self._ligne = ligne
    self._separator = ";"
    self._champs = 0
    self._nb_champs = 0
    self.initChamps()

  def initChamps(self):
    self._champs = self._ligne.rsplit(self._separator)
    self._nb_champs = len(self._champs)

  def GetChamps(self,pos):
    return self._champs[pos]

  def getNbChamps(self):
    return self._nb_champs



#################################
# Divers XML
#################################

def Elt(nom, attribut, fils):
  return "\n<" + nom + attribut + ">"  + fils + "\n</" + nom + ">"

def Tag(nom, attribut):
  return "\n<" + nom + attribut + "/>"

def Attribut(nom, valeur):
  return " " + nom + "=" + "\"" + valeur + "\""

def GetDate(ldate, heure=""):
  if heure == "" :
    return ldate[0:4] + "-" + ldate[4:6] + "-" + ldate[6:8]
  else :
    return ldate[0:4] + "-" + ldate[4:6] + "-" + ldate[6:8] + "T" + heure[0:2] + ":" + heure[2:4] + ":" +heure[4:6]

def PostEai(ip_port, adresse, xml):
  httpcon = httplib.HTTPConnection(ip_port)
  params = xml
  #headers = {}
  #headers = {"Content-type": "application/x-www-form-urlencoded",
  headers = {"Content-type": "text/xml",
           #"charset": "ISO-8859-1"}
           "charset": "utf-8"}
  try:
    httpcon.request("POST", adresse,
             params, headers)
  except socket.error, (value,message): 
    print "Ne peut envoyer la requete: " + message 
    sys.exit(1) 
  httpcon.close()


