#!/usr/bin/env Rscript
#PCA generated with PCAngsd
##Script plotting point PCA and lables PCA next to each other
args <- commandArgs(trailingOnly = TRUE)
inFilePath <- args[1]  
runID <- args[2]
MQ <- args[3]
outPath <- args[4]


#Plot results
    require(ggfortify)
    require(ggplot2)
    require(tidyverse)
    require(gsheet)
    require(fuzzyjoin)
    require(gridExtra)

partentsubFolder <- "/Ibex/bam_statistics/flagstats"
set_path<-paste(partenFolder,runID,partentsubFolder,sep="")


#setwd("/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_pool2_41120/Ibex/bam_statistics/flagstats")
#setwd("/ibex_genomics/raw_da#ta/ancient_raw_data/screening_rawdata/screening_run_pool1_41120/Ibex/bam_statistics/flagstats") #Pool1


MappingQuality=MQ
in_file<-"flagSumStats.txt"
in_file2<-paste("readSumStats_MQ", MappingQuality, ".txt", sep="")

flagStat_summary<-as.data.frame(read.table(in_file, header=TRUE, sep=",")) %>% 
                    select(Samples, Total_Reads, Mapped_Reads, Duplicates )

readSumStats<-as.data.frame(read.table(in_file2, header=TRUE, sep=",")) 



flagStat_summary<- flagStat_summary %>% mutate("Endogenous_DNA_unfilter[%]"=((Mapped_Reads/Total_Reads)*100)) %>% 
                                        mutate("FilteredReads_surfviving"=readSumStats$Mapped_reads) %>% 
                                        mutate("Endogenous_DNA_filter[%]"=((FilteredReads_surfviving/Total_Reads)*100)) %>% 
                                        mutate("RawReadNr_deviation_linemean[%]"=(-1*(((median(Total_Reads)-Total_Reads)/median(Total_Reads))*100))) %>%
                                        mutate("")

path_out<-paste(outPath,"/flagstatSummary.csv", sep="")

write_excel_csv(flagStat_summary, path=path_out)
}