'''
Use these functions with a csv file where the ASV IDs are inserted in the second column.
ASV_IDs can be generated with adding_ASV_ID.py
'''

import csv
import numpy as np
import argparse
import os
import matplotlib.pyplot as plt
import seaborn as sns
sns.set()


def DictionaryUniqueSpecies(file_name, min_reads, delim): 
	"""This function creates a dictionary with all the unique species. 
	First it counts how many reads there are in the rows, then it 
	counts how many fragments for species there exists in the table
	"""
	unique_species = {}
	with open(file_name) as csv_file:
	    csv_reader = csv.reader(csv_file, delimiter=delim)
	    header = next(csv_reader) # header
	    genus_species_index= len(header) - 1

	    for row in csv_reader:
	    	genus_species = row[genus_species_index]
	    	total_reads = 0

	    	for i in range (2,genus_species_index-7): total_reads += int(row[i])
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

def statistics(dictionary_species):
	count = 0
	frequency = np.array([0])
	count_sp = 0
	for key in unique_species:
		frequency = np.append(frequency, unique_species[key])
		if (unique_species[key] > 1):
			count += 1
			if (key[-3:] != "sp."):
				count_sp += 1

	return frequency, count, count_sp

def minimum_number_reads_vs_number_species(file_name, delim): #default x limit: 1000
	frequency = np.array([0])
	for min_reads in range(0,1000,20):
		unique_species = DictionaryUniqueSpecies(file_name, min_reads, delim)
		species = CountSpeciesWithoutSP(unique_species) if args.species else CountSpecies(unique_species)
		value = len(species)
		frequency = np.append(frequency, value)
	x = np.arange(0,1001,20)
	width = 15
	plt.bar(x, frequency, width, color='b')
	plt.xlabel("minimum number of reads")
	plt.ylabel("number of species")
	plt.show()
	return frequency

def minimum_number_reads_vs_total_number_ASVs(file_name, delim): #default x limit: 1000
	frequency = np.array([0])
	for min_reads in range(0,1000,25):
		unique_species = DictionaryUniqueSpecies(file_name, min_reads, delim)
		lista = []
		for key in unique_species.keys():
			lista.append(key)
		for key in lista:
			if unique_species[key] == 1:
				unique_species.pop(key)
		value = sum(unique_species.values())
		frequency = np.append(frequency, value)
	x = np.arange(0,1001,25)
	width = 23
	plt.bar(x, frequency, width, color='b')
	plt.xlabel("minimum number of reads")
	plt.ylabel("number of ASVs")
	plt.show()
	return frequency


def plot_frequency(frequency):
	sns.displot(frequency, bins=np.arange(1, frequency.max() +1)).set(title='Frequency plot, number of ASVs in the same species')
	plt.xlabel("# ASVs in one species")
	plt.show()
	
def plot_frequency_multipleASVs(frequency):
	sns.displot(frequency, bins=np.arange(2, frequency.max() +1)).set(title='Frequency plot, number of (not unique, x >= 2) ASVs in the same species')
	plt.xlabel("# ASVs in one species")
	plt.show()
	

parser = argparse.ArgumentParser()
parser.add_argument("file_name", type=str, help="name of the file")
parser.add_argument("min_reads", type=int, help="minimum number of reads in the row")
parser.add_argument("-sp", "--species", help="deleating sp.", action = "store_true")
parser.add_argument("-sc", "--semicolon", help="delimiter is semicolon (default = comma)", action = "store_true")
args = parser.parse_args()

delim = ";" if args.semicolon else ","

unique_species = DictionaryUniqueSpecies(args.file_name, args.min_reads, delim)

print ("Number of unique species: %s" %(len(unique_species)))

frequency, count, count_sp =  statistics(unique_species)

if (str(frequency) == str([0])):
	print ("check -sc to modify the delimiter (empty list of frequencies")
else:
	print ("Number of species with more than one ASV (total number of reads > %s): %s" %(args.min_reads,count))
	print ("Number of species with more than one ASV, excluding sp. (total number of reads > %s): %s" %(args.min_reads, count_sp))

	plot_frequency(frequency)
	plot_frequency_multipleASVs(frequency)
	minimum_number_reads_vs_number_species(args.file_name, delim)
	minimum_number_reads_vs_total_number_ASVs(args.file_name, delim)
