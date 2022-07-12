# PoolTool
# Equlibrate libraries for deep sequencing
The skripts in Pooling_Deepsequencing calculates flag statistics and from them the final ammount
of library in ul to be added for eacht sample to the pool 

## Installation
You can eather use the here provides conda environment or download the zipp file 
from the git repository and start form there

### Suggested: Using Annaconda 
Make sure to have R and git installed. 
Installation instructions for Anaconda can be found here: https://docs.anaconda.com/anaconda/install/
Installation instructions for git can be found here: 

Install PoolTool and samtools with the enviroment provided in the InstallationFolder using Anaconda
   
```bash
    git clone https://github.com/Ibexguy/Pooling_DeepSequencing.git
    cd Pooling_DeepSequencing/InstallationFolder
    conda env create -f PoolTool_v1.yaml
```
Also install the following packages in R:
```r
    install.packages(fuzzyjoin)
    install.packages(tidyverse)
    install.packages(plyr)
    install.packages(dplyr)
    install.packages(tidyr)
    install.packages(openxlsx)

```
### Run the PoolTool 
1. Specify all necessery parameters in the masterfile.sh
```bash
nano masterfile.sh #to edit the paths and parameters 
```
2. Make sure to have samtools indexd bamfiles else, do
```bash
samtools index *.bam
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
- flagstatSummary.xlx (contains all flagstat parameters and summary statistics with one sample per line)
- Line_optimisation.csv (contains information about how many lines are needed to get the desired coverage)
- Pooling_Scheme.xlx (Contains the sample name and amount of ul to be added to the pool to equalised coverage)