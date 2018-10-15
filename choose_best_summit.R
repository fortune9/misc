#!/bin/env Rscript

# functions
get_summit_dist<-function(s,e,summits)
{
	stopifnot(s<=e)
	summits<-as.numeric(unlist(strsplit(summits,",")))
	dists<-sapply(summits, function(x) {
		if(x > s && x < e) { return( -abs((s+e)/2-x)) } # within the region, return negative value
		if(x<=s) { return(s-x) } # before region
		return(x-e) # after region
		}
	)
	choose_best_dist(dists)
}

choose_best_dist<-function(dists)
{
	if(length(dists) == 1) { return( c(dists, 1) ) }
	# otherwise choose the best
	if(any(dists < 0)) { negativeIndice<-which(dists<0); best<-negativeIndice[which.max(dists[negativeIndice])]	}
	else { best<-which.min(dists) }
	return(c(dists[best], best))
}

usage<-function()
{
	message(
"Usage: choose_best_summit.R <closest-peak-file> [<outfile>]

This program reads the file containing the cloest peaks for
each TruSeq Methyl Capture region, and then choose the best
peak based on the closest summit and compute the distance to
summit.

<closest-peak-file>: the input file.

<outfile>: the file to store results. Default is to write to
terminal console.

e.g.: choose_best_summit.R truseq_methyl_vs_all_other_peaks.closest.bed truseq_methyl_vs_all_other_peaks.best_closest.csv

Created:  Thu Jul 19 02:04:06 EDT 2018
"
	)
}


inputs<-commandArgs(T)

if(length(inputs) < 1)
{
	usage();
	q("no")
}

inFile<-inputs[1]
outFile<-ifelse(is.na(inputs[2]), "", inputs[2])

message("# Reading data")
library(data.table)
dat<-fread(inFile,sep="\t")

setnames(dat, c("chr.trucap","start.trucap","end.trucap","name.trucap","sample","chr","start","end","peakName","abs_summit","summitName","pileup","fold_enrichment","-log10(qvalue)","-log10(pvalue)","distToPeak"))

message("# calculate the distance of trucap to the closest summit")
dat[,{res=get_summit_dist(start.trucap,end.trucap,abs_summit); list(distToSummit=res[1],closestSummit=res[2])},by=1:nrow(dat)]->tmp11
dat<-cbind(dat, tmp11[,2:3])

message("# choose the best summit for each trucap")
tmp11<-dat[,{best=choose_best_dist(distToSummit)[2]; .I[best]},by=.(name.trucap,sample)] 
dat[tmp11$V1,]->dat

idVars<-c("chr.trucap", "start.trucap", "end.trucap", "name.trucap")
aggVars<-setdiff(names(dat), c(idVars,"sample"))
castForm<-as.formula(paste(paste(idVars,collapse="+"), "sample", sep="~" ))

message("# Reshape the data")
dcast(dat, castForm, value.var=aggVars, sep=".", drop=c(T,T))->tmp11
setcolorder(tmp11, c(1:4,4+0:12*3+1, 4+0:12*3+2, 4+0:12*3+3))

write.csv(tmp11, file=outFile, row.names=F)
message("Job done!!")

