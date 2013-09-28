#Copyright Jon Berg , turtlemeat.com

import string,cgi,time
from os import curdir, sep, path
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
#import pri

class MyHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            if self.path.endswith(".html"):
                f = open(curdir + sep + self.path) #self.path has /test.html
#note that this potentially makes every file on your computer readable by the internet

                self.send_response(200)
                self.send_header('Content-type',	'text/html')
                self.end_headers()
                self.wfile.write(f.read())
                f.close()
                return
            if self.path.endswith(".esp"):   #our dynamic content
                self.send_response(200)
                self.send_header('Content-type',	'text/html')
                self.end_headers()
                self.wfile.write("hey, today is the" + str(time.localtime()[7]))
                self.wfile.write(" day in the year " + str(time.localtime()[0]))
                return
                
            return
                
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)
     

    def do_POST(self):
        global rootnode
        try:
            ctype , pdict = cgi.parse_header(self.headers.getheader('content-type'))
            clength = int(self.headers.get('Content-length'))
            xml = self.rfile.read(clength)
            #print ctype
            #print xml
            file_path = "./recu/file" + self.path.replace("/","_")
            i = 0
            while True:
              i = i + 1
              file_name = file_path + "." + string.zfill(str(i), 3) + ".xml"
              if not path.exists(file_name):
                 break
            f = open(file_name, "a")
            print " - reception taille trame : " + `clength`
            print self.headers
            print " - Ecriture fichier : " + file_name  + "\n"
            f.write(xml)
            f.close()
            
            #if ctype == 'multipart/form-data':
                #query=cgi.parse_multipart(self.rfile, pdict)
            #self.send_response(301)
            #self.end_headers()
            #upfilecontent = query.get('upfile')
            #self.wfile.write("<HTML>POST OK.<BR><BR>");
            #self.wfile.write(upfilecontent[0]);
            
        except :
            print "une erreur"
            pass

def main():
    try:
        server = HTTPServer(('163.104.211.157', 7002 ), MyHandler)
        print 'started httpserver...'
        server.serve_forever()
    except KeyboardInterrupt:
        print '^C received, shutting down server'
        server.socket.close()

if __name__ == '__main__':
    main()

