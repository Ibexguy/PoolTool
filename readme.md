# Todo
[ ] Add conda enviroment installation 

# Calculate amoutn of library for deep sequencing
The skripts in Pooling_Deepsequencing calculates flag statistics and from them the final ammount
of library in ul to be added for eacht sample to the pool 

1. Make sure to have samtools indexd bamfiles else, do
```bash
samtools index *.bam
```
2. Specify all necessery parameters in the masterfile.sh
```bash
nano masterfile.sh #to edit the paths and parameters 
```

3. Calculate flagstats with the follwoing comand
```bash 
bash 1-calculateFlagstats_Depth_length.sh  -m masterfile.sh
```

4. Calculate summary statistics and pooling sheme with the follwoing skript
```bash
bash  calculatePoolingScheme.sh -m masterfile.sh 
#or when you want to directly hand in parameters
bash  calculatePoolingScheme.sh -m masterfile.sh -l 4 -c 6 -u 5
```
Where: 
    -l = number of lanes [int]
    -c = aim coverage [int]
    -u = ul library per sample [int]"
5. The follwoing output is generated
- flagstatSummary.xlx (contains all flagstat parameters and summary statistics for each sample)
- Line_optimisation.csv (contains information about how many lines are needed to get the desired coverage)
- Pooling_Scheme.xlx (Contains the sample name and amount of ul to be added to the pool to get desired equmolarity)