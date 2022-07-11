#!/bin/bash
####################################################################################################################
#Rawdata anaylsis Screening Capra ibex
################################################################################################
# Make own folder, download data, produce mapping statistics and Post-Mortem-Damage
      #Can you make a snake-pipline out of it?
#https://snakemake.readthedocs.io/en/stable/tutorial/basics.html
#Define Paths
source masterfile

      mkdir $screening
      dedup=$screening/dedup
      data_w=$screening/multiplex
      work=$screening/work
      DMG=$screening/mapDMG
      trimmed=$screening/trimmed
      mapping=$screening/mapping
      bam_statistics=$screening/bam_statistics

      mkdir -p $data_w $work $DMG $trimmed $mapping $dedup $mapdamage $bam_statistics $bam_statistics/bamstats $bam_statistics/flagstats $bam_statistics/coverage $mapping/mapping_skripts $dedup/skripts

#Get sample names from files
      ls $fastqc_files | grep gz|  awk -F "_" '{print $3}'| uniq | awk -F "-" '{print $2 "-" $3}' > $work/samples.txt
      #Check sample Names and ajust if necessary
      nano $work/samples.txt && wait
#Copy data and rename the copy
      while read name; do 
      cp $fastqc_files/20210519.A-o24758_1_*-${name}*_R1.fastq.gz $work/demultiplexed_${name}_r1.fq.gz 
      cp $fastqc_files/20210519.A-o24758_1_*-${name}*_R2.fastq.gz $work/demultiplexed_${name}_r2.fq.gz 
      done < $work/samples.txt 
###Data Trimming, AdapterRemoval #######################################################
      while read Name; do 
      AdapterRemoval --combined-output --interleaved-output --file1 $work/demultiplexed_${Name}_r1.fq.gz --file2 $work/demultiplexed_${Name}_r2.fq.gz --basename $trimmed/${Name} --collapse 2>&1 |tee $work/$runID.log
      done < $work/samples.txt 

##############################################################
#Mapping (Details siehe bechreibung unten) 
### or use samtools view -bS insted of samtools view -F 4 (keeps only passing reads in)
skript=$mapping/mapping_skripts
      > $skript/bwa_skript_list
      while read Name; do
            echo -e '#!/bin/bash \n' >$skript/${Name}_bwa.sh
            echo "$bwa mem -R '@RG\tID:${Name}\tSM:${Name}\tPL:illumina\tLB:${Name}' -M \
            ${REFGENOME} \
            $trimmed/${Name}.paired.truncated | \
            samtools view -F 4 -o $mapping/${Name}_bwa_tmp.bam" >>$skript/${Name}_bwa.sh
            echo "samtools sort $mapping/${Name}_bwa_tmp.bam -o $mapping/${Name}_paired_sorted.bam" >>$skript/${Name}_bwa.sh
            echo "rm $mapping/${Name}_bwa_tmp.bam" >> $skript/${Name}_bwa.sh
            echo "samtools index $mapping/${Name}_paired_sorted.bam" >>$skript/${Name}_bwa.sh
            echo "$skript/${Name}_bwa.sh" >>$skript/bwa_skript_list
      done < $work/samples.txt
      
      #run in Parallel. 
      while read list; do
            echo "bash $list &> $mapping/$Name.maplog"
      done < $skript/bwa_skript_list | parallel -j $cores

    #Make list with path to all .sh skripts generated with the follwoing comand and write all the files 
    skript=$dedup/skripts
    > $skript/dub_skript_list


while read Name; do
    echo -e '#!/bin/bash \n' > $skript/${Name}_dublicates.sh
    #write a mark dublicate bash script, and tee in a temporary logfile
    echo "java -Xms7G -Xmx8G -jar /home/debian/picard/build/libs/picard.jar MarkDuplicates \
    INPUT=$mapping/${Name}_paired_sorted.bam \
    OUTPUT=$dedup/${Name}_dedup$Chrom.bam \
    VALIDATION_STRINGENCY=LENIENT \
    METRICS_FILE=$dedup/${Name}_dedub.metrics" >> $skript/${Name}_dublicates.sh

    #Index dedublicated files
    echo "samtools index $dedup/${Name}_dedup$Chrom.bam" >> $skript/${Name}_dublicates.sh
    echo "$skript/${Name}_dublicates.sh" >> $skript/dub_skript_list
done < $work/samples.txt

    while read list; do
    echo "bash $list &> $skript/$Name.dublog"
    done < $skript/dub_skript_list | parallel -j $cores


      #Get rid of NNNNs of colapsed reads from the adapter-removal step 
      while read Name; do
            echo "Removed colapsed read $Name"
            samtools view -h $dedup/${Name}_dedup$Chrom.bam | awk '$10 != "N" {print $0}' | samtools view -b > $dedup/${Name}.woNreads.bam
            samtools index $dedup/${Name}.woNreads.bam
      done < $work/samples.txt


