#entrez-do-dnames.list collected from disgenet
#based on the result you would get if you query disgenetquery.txt on http://rdf.imim.es/sparql and select tsv as result format
#however because of performance problems we queried directly the sql database resulting in the file we use here
#convert gmpl into rdf(using hack script, I already had) and load them into jena db
#fix the path and install jena 
python Main.py
rm -r ./tempdb
tdbloader -loc ./tempdb --graph=http://ssb.wur.nl/gpml out.ttl
#get all genes from each pathway
tdbquery --loc ./tempdb --query getnetquery1.txt > res.txt
tail -n +2 res.txt | sed 's/"//g' > res2.txt
#translate all identifiers to entrez identifiers using bridgedb, start bridgedb server
python translate.py
#remove any duplicate results
uniq finalres.txt > finalres2.txt
#Do enrichment analysis based on fisher test (fix the path)
R CMD BATCH main.R