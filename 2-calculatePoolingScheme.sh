#!/bin/bash
######################################################################
#Calculate Pooing sheme
#####################################################################

#Initialise function
helpFunction()
{
   echo ""
   echo "Usage: bash $0 -m masterfile.sh -l 4 -c 6 -u 5"
   printf "  -l = number of lanes [int]
            -c = aim coverage [int]
            -u = ul library per sample [int]"
   printf "masterfile.sh need exactly! the following form: 
        runID=screening_run_4.21
        in_path=/path/to/bamfiles
        out_path=/path/to/outpufiles
        sample_file_path=path/to/samples.txt #textfile with one sample name per line
        base_name=_dedup
        MappingQuality=30
        Chrom=23
        REFGENOME=/ibex_genomics/raw_data/refgenom/GCF_001704415.1_ARS1_genomic.renamed.fna
        MaxOutputReads_Sequencer=3360.99

"
   exit 1 # Exit script after printing help
}

while getopts "m:lcu" opt
do
   case "$opt" in
      m ) masterfile="$OPTARG" ;;
      l ) ul_library_to_pool="$OPTARG" ;;
      c ) coverage_final="$OPTARG" ;;
      u ) ul_library_to_pool="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$masterfile" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi
source $masterfile

Rscript --vanilla calculateFlagstatSummary.r $runID $out_path $sample_file_path $MappingQuality $number_lanes $ul_library_to_pool $coverage_final $MaxOutputReads_Sequencer

cat $out_path/Line_optimisation.csv | head -n 2 | awk -F:"," '{printf $1}'