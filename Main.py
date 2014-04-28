import xml.etree.ElementTree as ET
import os

#hack script to convert gmpl into RDF, could also have used RDF from wikegenes, but I already had this hack script for something else

namespaces = {'gpml': 'http://csb.wur.nl/gpml'} # add more as needed

idCounter = 0

def normalize(defns,name):
    if name[0] == "{":
        uri, tag = name[1:].split("}")
        return uri + "/" + tag
    else:
        return defns + "/" + name

def printNode(node,id,out):
    global idCounter 
    #for childs in node:
    #    printNode(childs)
    attribs = node.attrib
    ns, tag = node.tag[1:].split("}")
    out.write(id + " rdf:type <" + ns + "/" + tag + "> .\n")
    for attr in attribs:
        out.write(id + " <" + normalize(ns,attr) + "> \"" + attribs[attr].replace('\n', '\\n').replace('\"', '\\\"') + "\" .\n")
    for childs in node:
        childId = "xml:" + str(idCounter)
        idCounter += 1
        out.write(id + " xml:child " + childId + " .\n")
        printNode(childs,childId,out)    

def processAll(d,outFile):
    rootcount = 1
    out = open(outFile,"w+")  
    header = open("header.txt","r")
    out.write(header.read())
    header.close()
    for f in os.listdir(d):
        if(f.endswith(".gpml")):
            print(f)
            tree = ET.parse(d + "/" + f)
            root = tree.getroot()
            out.write("xml:root" + str(rootcount) + " rdf:type xml:Root .\n")
            printNode(root,"xml:root" + str(rootcount),out)
            rootcount += 1
         #   break
    out.close();  
    # do something
processAll("/home/jesse/code/python/wikipathwaysextract/gpml","out.ttl")



#print(root)
#for node in root.findall("xgmml:node",namespaces=namespaces):
#    print(node)


  



#printRoot(root,"res.ttl")

#alldata = open("maincor.xgmml","r").read()
#parser = ET.XMLPullParser(['start', 'end'])
#parser.feed(alldata)
#for event, elem in parser.read_events():
#  print(event)
#  print(elem.tag, 'text=', elem.text)