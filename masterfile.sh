#!/bin/bash
##############################################################################################
#Master file to define all paths and variables for the repooling aproach
##############################################################################################
#Mapping to deduplication
    runID=allSamples

      cores=6
      #Path to raw data
      fastqc_files=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/rawdata/NextSeq500_20210519_NS490_o24758_DataDelivery
      # to conda!
       bwa=/home/debian/bin/bwa/bwa
      screening=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/$runID/Ibex


#
    in_path=/net/cephfs/scratch/matrob/programs/Cluster_git/Cluster_Repo/Atlas-Pipelines/UpdateQulity/genolike
    out_path=~/scratch/programs/Cluster_git/Pooling_DeepSequencing/$runID/bam_statistics
    sample_file_path=/net/cephfs/scratch/matrob/programs/Cluster_git/Cluster_Repo/Atlas-Pipelines/UpdateQulity/genolike/sample_list.txt
    base_name=_recalibrated
#Variables for summary statistics
    MappingQuality=30
    Chrom=1
    REFGENOME=/home/cluster/matrob/data/programs/refgenome/Capra_hircus.ARS1.104.dna.toplevel.fa

#Variables for pooling scheme
    #Number of lines which are use in the sequencing run
    number_lanes=2

    #Number of ul of library, which should be added for each sample
    ul_library_to_pool=5

    #Final coverage to be achived over all runs
    coverage_final=6
     
    #Number of reads, the sequencer can produce 
    MaxOutputReads_Sequencer=3361 #In millions
