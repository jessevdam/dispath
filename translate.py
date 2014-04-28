#copyright Jesse van Dam

import urllib

#script to translate any not Entrez Gene identifier to a entrez gene identifier

webserviceUrl = "http://localhost:8183";

def mapID (id, code,outfile,pathway):
    species = "Human";# TODO: Add comment
# 
# Author: jesse
###############################################################################
    url = webserviceUrl + '/' + species + '/xrefs/' + code + '/' + id;
    data = urllib.urlopen (url).read();
    if(len(data.strip())==0 or data.startswith("<html>")):
        print("no res for " + code + ":" + id)
        return
    for line2 in data[0:-1].split("\n"):
        items2 = line2.strip().split("\t")
        if(line2 == "<html>"):
            print url
            print data
        if(items2[1] == "Entrez Gene"):
            #print(line2)
            outfile.write(pathway + "\t" + items2[0] + "\n")

outfile = open("finalres.txt","w")
infile = open("res2.txt","r")
for line in infile:
    items = line.strip().split("\t")
    if(items[1] != "Entrez Gene"):
        mapID(items[2],items[1],outfile,items[0])
    else:
        outfile.write(items[0] + "\t" + items[2] + "\n")
    
infile.close()
outfile.close()



## If you want to use a local bridgedb idmapper in python, setup a local service
## and change the url below. See http://bridgedb.org/wiki/LocalService
## for information on how to run a local service.





#mapID ("1234", "L");