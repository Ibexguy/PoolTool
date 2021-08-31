#!/bin/bash
######################################################################
#Generate flagstat summaries and calculate pooling
#####################################################################

#Initialise function
helpFunction()
{
   echo ""
   echo "Usage: bash $0 -m masterfile.sh"
   printf "masterfile.sh need exactly! the following form: 
      runID=screening_run_4.21
      in_path=/path/to/bamfiles
      out_path=/path/to/outpufiles
      sample_file_path=path/to/samples.txt #textfile with one sample name per line
      base_name=_dedup
      MappingQuality=30
      Chrom=23
      REFGENOME=/ibex_genomics/raw_data/refgenom/GCF_001704415.1_ARS1_genomic.renamed.fna
"
   exit 1 # Exit script after printing help
}

while getopts "m:" opt
do
   case "$opt" in
      m ) masterfile="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$masterfile" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

#Load masterfile  and make folders
source $masterfile
mkdir -p $out_path/flagstats
mkdir -p $out_path/summary

#Run Anylsis
#Flagstats
            while read Name; do
            echo "Producing Flagstats for $Name"
            echo "$Name" > $out_path/flagstats/$Name.flagstat_screening.txt
            samtools flagstat $in_path/${Name}${base_name}.bam >> $out_path/flagstats/$Name.flagstat_screening.txt
            done < ${sample_file_path}

      #Reformatting flagstat-files
            cat header_file_flagstat.txt > $out_path/summary/$runID.flagSumStats.txt
            while read Name; do
            echo "Reformatting header for $Name"
            cat $out_path/flagstats/$Name.flagstat_screening.txt | awk '{printf ($1"\t")}' | awk '{print ($0)}' >> $out_path/summary/$runID.flagSumStats.txt
            done < ${sample_file_path}

#Calculate depth 
#Calcualte depth and coverage (include quality checks --min-MQ 30 --min-BQ 30)
      #Produce header file
      header_file=$(ls $in_path | grep $base_name.bam | head -n 1)
      samtools coverage --reference $REFGENOME -r $Chrom $in_path/$header_file| grep '#' |  awk '{print "Name",$0}' OFS="\t" > $out_path/summary/$runID.samtoolsCov_Chrom$Chrom.txt

      #Calculate depth      
      while read Name; do
            echo "Calculate coverage with MQ $MappingQuality for $Name"
            samtools coverage --reference $REFGENOME --min-MQ $MappingQuality --min-BQ 30 -r $Chrom $in_path/${Name}${base_name}.bam | grep -v '^#' |  awk '{print variable,$0}' variable="$Name" OFS="\t" >> $out_path/summary/$runID.samtoolsCov_Chrom$Chrom.txt
      done < ${sample_file_path}

#Summ up reads with certain lenght (sort -n (numeric) -k 2 (column 2))
      echo -e "Sample\tN_reads" > $out_path/summary/readSumStats_MQ$MappingQuality.txt
      while read Name; do
            Num_passed_reads=$(samtools view $in_path/${Name}${base_name}.bam -q $MappingQuality | cut -f 10 | wc -l)
            echo -e "$Name\t$Num_passed_reads"
      done < ${sample_file_path} >>  $out_path/summary/readSumStats_MQ$MappingQuality.txt

      #Read length distribution
      while read Name; do
            echo "Calculate readlenght distribtuion of $Name"
            samtools view $in_path/${Name}${base_name}.bam -q $MappingQuality | cut -f 10 | perl -ne 'chomp;print length($_) . "\n"' | sort | uniq -c | sort -n -k 2 >>  $out_path/flagstats/$Name.readLenghtCountMQ$MappingQuality.txt
      done < ${sample_file_path}

#Run R skirpt to generate pooling sheme 
Rscript --vanilla calculateFlagstatSummary.r $runID $out_path $sample_file_path $MappingQuality $number_lanes $ul_library_to_pool $coverage_final