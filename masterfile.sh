#!/bin/bash
##############################################################################################
#Master file to define all paths and variables for the repooling approach
##############################################################################################
    runID=allSamples #Folder with this ID will be generated

    in_path=/path/to/deduplicated.bams #Path to parent folder containing the bams

    out_path=/outPath/to/wirte/files$runID/bam_statistics # #Outhpath to write summary statistics

    sample_file_path=/data/dedup/sample_list.txt #SampleFile containing one bam file per line. Produce with ls /path/to/bams/*.bam > sample_list.txt

    base_name=_dedup # eg. if a file is called sample1_dedup.bam -> base_name=_dedup

#Variables for summary statistics 
    MappingQuality=30 #Mapping quality to calculate endogenous DNA content and summary statistics

    Chrom=1 #Chromosome to base coverage information on, must have the same name as in the reference genome. 

    REFGENOME=path/to/refgenome.fa #Path/to/reference.genome.fa

#Variables for pooling scheme 
    #Number of lines which are use in the sequencing run
    number_lanes=2

    #Number of ul of library, which should be added for each sample
    ul_library_to_pool=5

    #Final coverage to be achived over all runs
    coverage_final=6
     
    #Number of reads, the sequencer can produce per lines
    MaxOutputReads_Sequencer=3361 #In millions

    #Persetnage of High quality reads with Base Quality >30
    HighQualityReads=0.923