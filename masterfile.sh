#!/bin/bash
#Masterfile for flagstat summary
    runID=allSamples
    in_path=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/$runID/Ibex/dedup
    out_path=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/$runID/Ibex/bam_statistics
    sample_file_path=/home/cluster/matrob/scratch/programs/Cluster_git/Cluster_Repo/Angsd-Pipelines/Sample_list/sample_list_extendedAllCaprines.txt
    base_name=_recalibrated
#Variables for summary statistics
    MappingQuality=30
    Chrom=1
    REFGENOME=/ibex_genomics/raw_data/refgenom/GCF_001704415.1_ARS1_genomic.renamed.fna

#Variables for pooling scheme
    #Number of lines which are use in the sequencing run
    number_lanes=2

    #Number of ul of library, which should be added for each sample
    ul_library_to_pool=5

    #Final coverage to be achived over all runs
    coverage_final=6
     
    #Number of reads, the sequencer can produce 
    MaxOutputReads_Sequencer=3361 #In millions