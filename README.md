# Analyzing ASVs data from DADA2 output

This repository is a collection of python and R scripts, which together consitute a pipeline for the analysis of ASVs data from the software DADA2 (https://github.com/benjjneb/dada2). 
Amplicon Sequence Variants (ASVs) are short sequences of DNA that are recovered from a high-throughput marker gene analysis. DADA2 attempts at associating a taxonomy classification on a species level to each ASVs. 

For each species, multiple distint ASVs can be matched by the software. With these scripts it is possible to group (in different files) ASVs that matches to the same species (python scripts), and start an analysis on a species level (R script).

This README file provides an overwiev of the repository and contains instructions regarding the usage of the scripts. 

---

## adding_ASV_ID.py
Starting from the DADA2 output, this file adds a second column (after the one with the DNA sequences) with the ASV_ID. For example, if the DADA2 output file with file_name = *output_dada2.csv* has 100 rows, than the new file is called *output_dada2_ASV.csv* and in the second column a label that ranges from *ASV_001* to *ASV_100* is stored. 
**IMPORTANT** the output ASV_ID file is generated inside a folder called *Data*. If this folder is not already present, this should be created manually in the same folder of this script. 

`usage` : adding_ASV_ID.py [-h] [-sc] file_name

`positional arguments`:

file_name      -   name of the file

`optional arguments`:
			  
-sc, --semicolon - delimiter is semicolon (default = comma)

---

## extracting_asvs.py
This file separates in different folders all the ASVs that match to the same species. 
**IMPORTANT** only *xxx_ASV.csv* files can be given as an input. These files have as a second column the ASV_ID and they can be obtained by the file *adding_ASV_ID.py* (read the paragraph above) from the output of DADA2 . 
<br>
In a folder called `results`, a new folder with the same name of the input file is created. Inside this folder every species with multiple ASVs has an individual file including all matching ASVs. 
ASVs with only a few reads (summing over all samples) can be excluded from the results folder by inserting an abundancy threshold (minimum number of reads, *min_reads*).

Before actually creating the files, the total number of species files is computed and the user is asked whether he wants to continue. This number can be regulated by adjusting min_reads (increasing min_reds would cut off more ASVs and reduce the total number of generated files). 


`usage` extracting_asvs.py [-h] [-sp] [-sc] file_name min_reads

`positional arguments`: 

file_name    -     name of the file
<br>
min_reads    -     minimum number of reads for an ASVs (summing over all samples)

`optional arguments`:

-sp, --species  -   excluding *sp.* from the results. These ASVs are only associated with a genus, not with a species (ex. *Cyclotella sp.*)
<br>
-sc, --semicolon  delimiter is semicolon (default = comma)

---

## asvs_statistics.py
This script aims at giving an overview of the file from DADA2, in terms of number of ASVs. As in *extracting_asvs.py*, only *xxx_ASV.csv* files can be analized. 

First, the total number of species is computed. This value only considers the ASVs with a taxonomy classification on a **species** level (this value can be missing in some cases). 
Then, the total number of species in the file, excluding the ones where the last centry in the DADA2 taxonomy classification ends with *sp.* (e.g DADA2 was able to identify only the genus). 

After this, two frequency plots are shown. 
In the first one, we can have an idea of how many ASVs are generally assigned to the same species. For x=1, just a unique ASVs was associated to the species. 
As it is likely that x=1 occurs most of the time, in the second plot the minimum value for x is 2, in this way it is possible to visualize only *not-unique* ASVs. 
<br>
Finally, two other plots are displayed. Thess plots analyze how the parameter *min_reads* influences the number of ASVs in the result. As this parameter varies, the number of files (third plot) and the total number of ASVs (fourth plot) change as well.   

`usage` asvs_statistics.py [-h] [-sp] [-sc] file_name min_reads

`positional arguments`: 

file_name    -     name of the file
<br>
min_reads    -     minimum number of reads for an ASVs (summing over all samples)

`optional arguments`:

-sp, --species  -   excluding *sp.* from the results. These ASVs are only associated with a genus, not with a species (ex. *Cyclotella sp.*)
<br>
-sc, --semicolon  delimiter is semicolon (default = comma)

---

## simply_collapsing.py 

This file collapses together all the rows assigned to the same species, such that the reads count for each sample are summed and the fragment sequences are not showed anymore. After collapsing together these rows, the new rows are ordered again such that in the output file the rows are ordered from the most to the least abundant taxon, as in the original Dada2 output. The resulting file is saved in the results folder (as \**file_name*\*_collapsed.csv). 

`usage` simply_collapsing_ASVs.py [-h] file_name

`positional arguments`:

  file_name - name of the file

---

## plot_directory_ASVS.R

check the file **test_plots.html** for the R script. 


