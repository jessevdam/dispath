#copyright Jesse van Dam, Núria Queralt, Janet Pinero Glez

#this script calculate enrichment for each pathway and for each disease using fisher test
#it result sensable results, but there could be still errors in as we just finished it at the end of biothing hackathon
#results
##all.tsv -> complete matrix of all enrichment tests
##enrich.txt -> significantly enriched disceases for each pathway
##enrich2.txt -> significantly enriched pathways for each discease
setwd("/home/jesse/code/python/wikipathwaysextract")

dis <- read.table("entrez-do-dnames.list",header=TRUE,sep="\t",quote="")
pathway <- read.table("finalres2.txt",sep="\t")

#dis[1:5,]
#pathway[1:5,]

allDis <- unique(dis$diseaseName)
allPath <- unique(pathway$V1)

#get all unique genes that match both a pathway and a decease
disTotalUniq <- length(unique(dis$geneid))
pathTotalUniq <- length(unique(pathway$V2))
background <- length(intersect(unique(dis$geneid),unique(pathway$V2)))

#get the list of unqiue genes per disease and pathway
disGeneList <- lapply(allDis,function(d) {unique(dis$geneid[which(dis$diseaseName == d)])})
pathGeneList <- lapply(allPath,function(d) {unique(pathway$V2[which(pathway$V1 == d)])})

#count the number of unique genees per desease and pathway
disGeneCount <- as.matrix(lapply(disGeneList,function(d) {length(d)}))
rownames(disGeneCount) <- allDis

pathGeneCount <- as.matrix(lapply(pathGeneList,function(d) {length(d)}))
rownames(pathGeneCount) <- allPath

#calulate the p value per combi
m <- matrix(nrow = length(allPath), ncol = length(allDis))
rownames(m) <- allPath
colnames(m) <- allDis

for(i in 1:length(allPath)) { #length(allPath)
	pathItem <- allPath[i]
	print(pathItem)
	for(j in 1:length(allDis)) { #length(allDis)		
		disItem <- allDis[j]
		common <- length(intersect(disGeneList[j][[1]],pathGeneList[i][[1]]))
		if(common > 0)
		{  
		  print(paste(pathItem," - ",disItem,"(",i,",",j,")"))
		  disNonCommon <- disGeneCount[j,1][[1]] - common
		  pathNonCommon <- pathGeneCount[i,1][[1]] - common
		  t <- array( c(common,
						disNonCommon,
						pathNonCommon,
						background + common - disNonCommon - pathNonCommon),
				dim=c(2,2))
		  print(t)
		  test<-fisher.test(t, alternative="greater")
		  pval <-test$p.value
		  m[i,j] <- pval
	  }
	}
}

write.table(m,"allraw.tsv")

#do correction for multiple testing
res <- t(apply(m,1,function(val) {p.adjust(val,"BH")}))
write.table(m,"all.tsv")
#res <- read.table("all.txt")
finalRes <- matrix("",nrow = length(allPath), ncol = 2)
colnames(finalRes) <- c("pathway","deceacelist")
for(i in 1:length(allPath))
{
  finalRes[i,1] <- paste(allPath[i])
  finalRes[i,2] <- paste(allDis[which(res[i,] < 0.05)],collapse=";")
  #finalRes <- rbind(finalRes,c(allPath[i],paste(allDis[which(res[i,] < 0.05)],collapse=";")))
}
write.table(finalRes,"enrich.txt")

#do correcton for multiple testing but now per decease 
res <- apply(m,2,function(val) {p.adjust(val,"BH")})
finalRes <- matrix("",nrow = length(allDis), ncol = 2)
colnames(finalRes) <- c("pathway","deceacelist")
for(i in 1:length(allDis))
{
	finalRes[i,1] <- paste(allDis[i])
	finalRes[i,2] <- paste(allPath[which(res[,i] < 0.05)],collapse=";")
	#finalRes <- rbind(finalRes,c(allPath[i],paste(allDis[which(res[i,] < 0.05)],collapse=";")))
}
write.table(finalRes,"enrich2.txt")

p.adjust()