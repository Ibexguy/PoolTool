#!/bin/bash
#Masterfile for flagstat summary
    runID=screening_run_4.21
    in_path=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/Ibex/dedup
    out_path=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/Ibex/bam_statistics
    sample_file_path=/ibex_genomics/raw_data/ancient_raw_data/screening_rawdata/screening_run_4.21/Ibex/work/samples.txt 
    base_name=_dedup
#Variables for summary statistics
    MappingQuality=30
    Chrom=1
    REFGENOME=/ibex_genomics/raw_data/refgenom/GCF_001704415.1_ARS1_genomic.renamed.fna
    MaxOutputReads_Sequencer=3360.99 #In millions
#Variables for pooling scheme
    #Number of lines which are use in the sequencing run
    number_lanes=2

    #Number of ul of library, which should be added for each sample
    ul_library_to_pool=5

    #Final coverage to be achived over all runs
    coverage_final=6
     
    #Number of reads, the sequencer can produce 
   