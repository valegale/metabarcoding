# Analyzing ASVs data from DADA2 output

This repository is a collection of python and R scripts, which together consitute a pipeline for the analysis of ASVs data from the software DADA2 (https://github.com/benjjneb/dada2). 

This README file provides an overwiev of the repository and contains instructions regarding the usage of the scripts. 

---

## adding_ASV_ID.py
Starting from the DADA2 output, this file adds a second column (after the one with the DNA sequences) with the ASV_ID. For example, if the DADA2 output file with file_name = *output_dada2.csv* has 100 rows, than the new file is called *output_dada2_ASV.csv* and in the second column a label is stored that ranges from *ASV_001* to *ASV_100*. 

`usage` : adding_ASV_ID.py [-h] [-sc] file_name

`positional arguments`:

file_name      -   name of the file

`optional arguments`:
			  
-sc, --semicolon - delimiter is semicolon (default = comma)

---

## extracting_asvs.py
This file separates in different folders all the ASVs that match to the same species. First, a number is assigned to each ASV from the most abundant (ex. ASV_001) to the least abundant. Then, in a folder called `results` a folder with the same name of the input file is created. Inside this folder every species with multiple ASVs has an individual file, with all the matching ASVs. 

**IMPORTANT** only *x_ASV.csv* files can be given as an input. These files has as a second column the ASV_ID and they can be obtained by the file *adding_ASV_ID.py* from the output of DADA2. 

ASVs with only a few reads (summing over all samples) can be excluded from the results folder by inserting an abundancy threshold (minimum number of reads, *min_reads*).

Before actually creating the files, the total number of species files is computed and the user is asked whether he wants to continue. This number can be regulated by adjusting min_reads. 


`usage` extracting_asvs.py [-h] [-sp] [-sc] file_name min_reads

`positional arguments`: 

file_name    -     name of the file

min_reads       - minimum number of reads for an ASVs (summing over all samples)

`optional arguments`:

-sp, --species  -   excluding *sp.* from the results. These ASVs are only associated with a genus, not with a species (ex. *Cyclotella sp.*)

-sc, --semicolon  delimiter is semicolon (default = comma)

---


## asvs_statistics.py


