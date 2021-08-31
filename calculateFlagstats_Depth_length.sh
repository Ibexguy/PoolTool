#!/bin/bash
######################################################################
#Generate flagstat summaries and calculate pooling
#####################################################################
#Read in paths from master file 
$1=master_file 
source $master_file


#Flagstats
            while read Name; do
            echo "Producing Flagstats for $Name"
            echo "$Name" > $out_path/flagstats/$Name.flagstat_screening.txt
            samtools flagstat $in_path/${Name}${base_name}.bam >> $out_path/flagstats/$Name.flagstat_screening.txt
            done < ${sample_file_path}

      #Reformatting flagstat-files
            cat /ibex_genomics/skripts/header_file_flagstat.txt > $out_path/$runID.flagSumStats.txt
            while read Name; do
            cat $out_path/flagstats/$Name.flagstat_screening.txt | awk '{printf ($1",")}' | awk '{print ($0)}' >> $out_path/$runID.flagSumStats.txt
            done < ${sample_file_path}


#Summ up reads with certain lenght (sort -n (numeric) -k 2 (column 2))
      while read Name; do
      Num_passed_reads=`samtools view $in_path/${Name}${base_name}.bam -q $MappingQuality | cut -f 10 | wc -l`
      echo -e "$Name,$Num_passed_reads"
      done < ${sample_file_path} >>  $out_path/flagstats/readSumStats_MQ$MappingQuality.txt

      #Read length distribution
      while read Name; do
      samtools view $in_path/${Name}${base_name}.bam -q $MappingQuality | cut -f 10 | perl -ne 'chomp;print length($_) . "\n"' | sort | uniq -c | sort -n -k 2 >>  $out_path/$Name.readLenghtCountMQ$MappingQuality.txt
      done < ${sample_file_path}