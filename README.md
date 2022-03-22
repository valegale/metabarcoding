# Analyzing ASVs data from DADA2 output

This repository is a collection of python and R scripts, which together consitute a pipeline for the analysis of ASVs data from the software DADA2 (https://github.com/benjjneb/dada2). 
This README file provides an overwiev of the repository and contains instructions regarding the usage of the scripts. 
 

## Extracting_asvs.py
This file separates in different folders all the ASVs that match to the same species. First, a number is assigned to each ASV from the most abundant (ex. ASV_001) to the least abundant. Then, in a folder called `results` a folder with the same name of the input file is created. Inside this folder every species with multiple ASVs has an individual file, with all the matching ASVs. 
ASVs with only a few reads (summing over all samples) can be excluded from the results folder by inserting an abundancy threshold (minimum number of reads, *min_reads*).

`usage` extracting_asvs.py [-h] [-sp] [-sc] file_name min_reads

`positional arguments`:
  file_name         name of the file
  min_reads         minimum number of reads for an ASVs (summing over all samples)

`optional arguments`:
  -h, --help        show this help message and exit
  -sp, --species    excluding *sp.* from the results.  
 					These ASVs are only associated with a genus, not with a species (ex. *Cyclotella sp.*)
  -sc, --semicolon  delimiter is semicolon (default = comma)




