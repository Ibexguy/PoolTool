#!/usr/bin/env Rscript
#PCA generated with PCAngsd
##Script plotting point PCA and lables PCA next to each other

args <- commandArgs(trailingOnly = TRUE)
runID <- args[1]
outPath <- args[2]
sample_file_path <- args[3]
MappingQuality <- as.numeric(args[4])
number_lanes<-as.numeric(args[5])
ul_library_to_pool<-as.numeric(args[6])
coverage_final<-as.numeric(args[7])
MaxOutputReads_Sequencer<-as.numeric(args[8])

#for testing and debuging
    #runID<-"screening_run_4.21"
    #out_path<-"/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/Ibex/bam_statistics"
    #sample_file_path<-"/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/Ibex/work/samples.txt"

    #Variables for summary statistics
    #MappingQuality<-30
    #number_lanes<-3
    #ul_library_to_pool=5
    #coverage_final=6
#

#Generate output Table
    require(fuzzyjoin)
    library(tidyverse)
    library(plyr)
    library(dplyr)
    library(tidyr)
    library(openxlsx)


#Setting folders and paths 
    subFolder <- "summary"
    in_path<-paste(outPath,subFolder,sep="/")
    input_files<-list.files(in_path,include.dirs = TRUE)
    in_file<-list()

    for (i in 1:length(input_files)) {
        x<-paste(in_path,input_files[[i]],sep="/")
        in_file[[i]]<-read_delim(x,"\t")
    }

a<-regex_left_join(in_file[[1]],in_file[[2]],by=c("Sample"="Sample_name"))
jointData<-regex_left_join(a,in_file[[3]],by=c("Sample"="Name"))
#Read in files

#Calculate mean of depth and ajust vollume for new pool 
#number of lines per sample
HighQualityReads<-0.923 #Reads with Quality > 30
factor<-10^6

jointData<- jointData %>% drop_na() %>% mutate("EndogDNA[%]"=((Mapped_Reads/`Total_Reads[QC-passed+failed]`)*100)) %>% 
                                        mutate("EndogDNA_MQ30[%]"=((Mapped_Reads_MQ30/`Total_Reads[QC-passed+failed]`)*100)) %>% 
                                        mutate("Read_for_1Cov"=(`Total_Reads[QC-passed+failed]`/meandepth)) %>% 
                                        mutate("Coverage_aim"=coverage_final) %>%
                                        mutate("Coverage_per_Line"=coverage_final/number_lanes)%>%
                                        mutate("Rawreads_for_CoverageAim"=Coverage_per_Line*Read_for_1Cov) %>%
                                        mutate("Sequencer_Total_Reads"=MaxOutputReads_Sequencer*HighQualityReads*factor) %>%
                                        mutate("Sequencing_Overhead"=(MaxOutputReads_Sequencer/sum(Rawreads_for_CoverageAim))) %>%
                                        mutate("Additional_Lines_needed"=number_lanes-(number_lanes/Sequencing_Overhead))%>%
                                        mutate("Amount_of_Lane_used"=(Rawreads_for_CoverageAim/sum(Rawreads_for_CoverageAim))) %>%
                                        mutate("Library_to_pool"=sum(nrow(jointData)*ul_library_to_pool)*Amount_of_Lane_used)




Pooling_Scheme<- jointData %>% select("Sample_name",
                        "Library_to_pool")

Line_optimisation<- jointData %>% select("Sample_name",
                        "EndogDNA[%]",
                        "EndogDNA_MQ30[%]",
                        "Coverage_aim",
                        "Coverage_per_Line",
                        "Rawreads_for_CoverageAim",
                        "Sequencing_Overhead",
                        "Sequencer_Total_Reads",
                        "Additional_Lines_needed")
                                        #mutate("RawReadNr_deviation_linemean[%]"=(-1*(((median(Total_Reads)-Total_Reads)/median(Total_Reads))*100))) %>%
                                        
path_out<-paste(outPath,"Pooling_Scheme.xlx", sep="/")
write.xlsx(Pooling_Scheme,path_out,overwrite=TRUE)

path_out<-paste(outPath,"Line_optimisation.xlx", sep="/")
write.xlsx(Line_optimisation,path_out,overwrite=TRUE)

path_out<-paste(outPath,"flagstatSummary.xlx", sep="/")
write.xlsx(jointData, path_out,overwrite=TRUE)