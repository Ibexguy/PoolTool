#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
runID <- args[1]
outPath <- args[2]
sample_file_path <- args[3]
MappingQuality <- as.numeric(args[4])
number_lanes<-as.numeric(args[5])
ul_library_to_pool<-as.numeric(args[6])
coverage_final<-as.numeric(args[7])
MaxOutputReads_Sequencer<-as.numeric(args[8])
HighQualityReads<-as.numeric(args[9])


#Generate output Table
    require(fuzzyjoin)
    require(tidyverse)
    require(plyr)
    require(dplyr)
    require(tidyr)
    require(writexl)


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
#Factor to multiply the number of million reads the sequencer is capable of produceing 
factor<-10^6

jointData<-jointData %>% drop_na()
summaryCalculations<-jointData %>% drop_na() %>% mutate("EndogDNA[%]"=((Mapped_Reads/`Total_Reads[QC-passed+failed]`)*100)) %>% 
                                        mutate("EndogDNA_MQ30[%]"=((Mapped_Reads_MQ30/`Total_Reads[QC-passed+failed]`)*100)) %>%
                                        mutate("Read_for_1Cov"=(`Total_Reads[QC-passed+failed]`/meandepth)) %>%
                                        mutate("Total_Lines"=number_lanes) %>%
                                        mutate("Coverage_aim"=coverage_final) %>%
                                        mutate("Mean_Read_Depth_MQ30"=meandepth) %>%
                                        mutate("Coverage_per_Line"=coverage_final/number_lanes)%>%
                                        mutate("Rawreads_for_CoverageAim"=Coverage_per_Line*Read_for_1Cov) %>%
                                        mutate("Sequencer_Total_Reads"=MaxOutputReads_Sequencer*HighQualityReads*factor) %>%
                                        mutate("Sequencing_Overhead"=(Sequencer_Total_Reads/sum(Rawreads_for_CoverageAim))) %>%
                                        mutate("Additional_Lines_needed"=number_lanes-(number_lanes*Sequencing_Overhead))%>%
                                        mutate("Final_coverage_sample"=(number_lanes*Sequencer_Total_Reads)/sum(Read_for_1Cov))%>%
                                        mutate("yl_Coverage_aim"=(Rawreads_for_CoverageAim)/(`Total_Reads[QC-passed+failed]`/ul_library_to_pool))%>%
                                        mutate("Library_to_pool"=yl_Coverage_aim/sum(yl_Coverage_aim)*(nrow(jointData)*ul_library_to_pool))


masterTable<-summaryCalculations %>% select(Sample,
                                    `EndogDNA_MQ30[%]`,
                                    Mean_Read_Depth_MQ30, 
                                    Read_for_1Cov,
                                    Total_Lines,
                                    Coverage_aim,
                                    Coverage_per_Line,
                                    Rawreads_for_CoverageAim,
                                    Sequencer_Total_Reads,
                                    Sequencing_Overhead,
                                    Additional_Lines_needed,
                                    Final_coverage_sample,
                                    Library_to_pool)

Pooling_Scheme<- summaryCalculations %>% select("Sample_name",
                        "Library_to_pool")

Line_optimisation<-summaryCalculations %>% select("Sample_name",
                        "EndogDNA_MQ30[%]",
                        "Total_Lines",
                        "Coverage_aim",
                        "Coverage_per_Line",
                        "Rawreads_for_CoverageAim",
                        "Sequencing_Overhead",
                        "Sequencer_Total_Reads",
                        "Additional_Lines_needed",
                        "Final_coverage_sample")
                                        

path_out<-paste(outPath,"Pooling_Scheme.xlsx", sep="/")
write_xlsx(Pooling_Scheme,path_out)

path_out<-paste(outPath,"Line_optimisation.xlsx", sep="/")
write_xlsx(Line_optimisation,path_out)

path_out<-paste(outPath,"flagstatSummary.xlsx", sep="/")
write_xlsx(masterTable, path_out)
