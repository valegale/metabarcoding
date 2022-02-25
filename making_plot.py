import argparse
import csv
import os
import numpy as np
import seaborn as sns
sns.set()
import numpy as np
import itertools
import Bio
from Bio.Seq import Seq
from Bio import pairwise2
from Bio.pairwise2 import format_alignment
from Bio.SeqRecord import SeqRecord
from Bio.Align import MultipleSeqAlignment
import sys
import os
import matplotlib.pyplot as plt


def DictionaryUniqueSpecies(file_name, min_reads): 
	"""This function creates a dictionary with all the unique species. 
	First it counts how many reads there are in the rows, then it 
	counts how many fragments for species there exists in the table
	"""
	unique_species = {}
	with open(file_name) as csv_file:
	    csv_reader = csv.reader(csv_file, delimiter=';')
	    header = next(csv_reader) # header
	    genus_species_index= len(header) - 1
	    for row in csv_reader:
	    	genus_species = row[genus_species_index]
	    	total_reads = 0

	    	for i in range (1,genus_species_index-7): total_reads += int(row[i])
	    	if (genus_species!= "NA") and (total_reads >= min_reads):
	    		if genus_species not in unique_species:
	    			unique_species[genus_species] = 1
	    		else: 
	    			unique_species[genus_species] += 1
	    return unique_species


def CountSpecies(dictionary_species):
	"""Count the species with more than 1 fragment
	"""
	species = []
	for key in dictionary_species:
		if (dictionary_species[key] >= 2):
			species.append(key)
	return species

def CountSpeciesWithoutSP(dictionary_species):
	"""Count the species with more than 1 fragment, keep ony the species without sp.
	"""
	species = []
	for key in unique_species:
		if (unique_species[key] >= 2) and (key[-3:] != "sp."):
			species.append(key)
	return species

def create_file(file_table, folder, name_species, min_reads):
	if (name_species[-3:] == "sp."):
		name_file = os.path.join(folder, "%s.csv"%name_species[:-1])
	else:
		name_file = os.path.join(folder, "%s.csv"%name_species)
	print (name_file, " has been created")
	new_file = open(name_file, "w", newline='')
	with open(file_table) as csv_file:
	    csv_reader = csv.reader(csv_file, delimiter=';')
	    csv_writer = csv.writer(new_file)
	    header = next(csv_reader) # header
	    genus_species_index= len(header) - 1
	    for row in csv_reader:
	    	total_reads = 0
	    	for i in range (1,genus_species_index-7): total_reads += int(row[i])
	    	
	    	if (row[genus_species_index] == name_species) and (total_reads >= min_reads):
	    		csv_writer.writerow(row)
	new_file.close()
	return 

def CountFiles(file_name):

	frequency = np.array([0])
	for min_reads in range(0,1100,20):
		print (min_reads)
		unique_species = DictionaryUniqueSpecies(file_name, min_reads)
		species = CountSpeciesWithoutSP(unique_species) if sp else CountSpecies(unique_species)
		value = len(species)
		frequency = np.append(frequency, value)
	x = np.arange(0,1101,20)
	print (len(x))
	print (len(frequency))
	width = 15
	plt.bar(x, frequency, width, color='b')
	plt.xlabel("minimum number of reads")
	plt.ylabel("number of species")
	plt.show()
	return frequency

#parsing

file_name = 'data/seqtab_nonchim_id.csv'
file_name = '../Umweltmetagenomics/seqtab_nonchim_id.csv'
min_reads = 20

sp = False

frequency = np.array([0])

for min_reads in range(0,1000,25):
	print (min_reads)
	unique_species = DictionaryUniqueSpecies(file_name, min_reads)
	lista = []
	for key in unique_species.keys():
		lista.append(key)
	for key in lista:
		if unique_species[key] == 1:
			unique_species.pop(key)
	
	value = sum(unique_species.values())
	frequency = np.append(frequency, value)

x = np.arange(0,1001,25)
print (len(x))
print (len(frequency))
width = 23
plt.bar(x, frequency, width, color='b')
plt.xlabel("minimum number of reads")
plt.ylabel("number of ASVs")
plt.show()


'''
frequency = CountFiles(file_name)




args = parser.parse_args()
parser = argparse.ArgumentParser()
parser.add_argument("file_name", type=str, help="name of the file")
parser.add_argument("min_reads", type=int, help="minimum number of reads in the row")
parser.add_argument("-sp", "--species", help="deleating sp.", action = "store_true")

args = parser.parse_args()

unique_species = DictionaryUniqueSpecies(args.file_name, args.min_reads)

species = CountSpeciesWithoutSP(unique_species) if args.species else CountSpecies(unique_species)
print ("You will create %s files" %(len(species)))
proceed = True if (input("Do you want to proceed? Type y/n") == "y") else False

if proceed:

    # Create target Directory
    dirName = "results2"
    try:
    	os.mkdir(dirName)
    	print("Directory " , dirName ,  " Created ") 
    except FileExistsError:
    	print("Directory " , dirName ,  " already exists")
    
    # creating the files
    for sp in species:
    	create_file(args.file_name, dirName, sp, args.min_reads)
'''