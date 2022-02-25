import csv
import matplotlib.pyplot as plt
import seaborn as sns
sns.set()
import numpy as np

div4 = 'div4_seqtab_nonchim_main3_pr2_id.tsv'
euk = 'euk15_seqtab_nonchim_main3_pr2_id.tsv'
no_mism = "../results_taxa/nomism_new.csv"
mism = "../data/mism_new.csv"
table = '../data/nomism_new.csv'


unique_species = {}
with open(table) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    next(csv_reader) # header
    for row in csv_reader:
    	genus_species = row[49]
    	if (genus_species!= "NA"):
    		if genus_species not in unique_species:
    			unique_species[genus_species] = 1
    		else: 
    			unique_species[genus_species] += 1

print ("Number of unique species: %s" %(len(unique_species)))

count = 0
frequency = np.array([0])
count_sp = 0
for key in unique_species:
	frequency = np.append(frequency, unique_species[key])
	if (unique_species[key] > 1):
		count += 1
		if (key[-3:] == "sp."):
			count_sp += 1
print (frequency)

print ("Number of species with more than a fragment: %s" %(count))
print ("Number of species with more than a fragment (sp.): %s" %(count_sp))

# plotting unique species with more than 2 fragments
sns.displot(frequency, bins=np.arange(2, frequency.max() +1))
plt.show()

print (frequency)
# printing all frequencies
nr_fragments, counts_nr_fragments = np.unique(frequency, return_counts=True)
#print(dict(zip(nr_fragments, counts_nr_fragments)))

