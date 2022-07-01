#!/bin/bash
#Masterfile for flagstat summary
    runID=allSamples
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