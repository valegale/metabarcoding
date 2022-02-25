import argparse
import csv
import os


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
	for key in unique_species:
		if (unique_species[key] >= 2):
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

def create_file(file_table, folder, name_species, min_reads, delim):
	if (name_species[-3:] == "sp."):
		name_file = os.path.join(folder, "%s.csv"%name_species[:-1])
	else:
		name_file = os.path.join(folder, "%s.csv"%name_species)
	print (name_file, " has been created")
	new_file = open(name_file, "w", newline='')
	with open(file_table) as csv_file:
	    csv_reader = csv.reader(csv_file, delimiter=delim)
	    csv_writer = csv.writer(new_file)
	    header = next(csv_reader) # header
	    genus_species_index= len(header) - 1
	    csv_writer.writerow(header)
	    for row in csv_reader:
	    	total_reads = 0
	    	for i in range (2,genus_species_index-7): total_reads += int(row[i])
	    	
	    	if (row[genus_species_index] == name_species) and (total_reads >= min_reads):
	    		csv_writer.writerow(row)
	new_file.close()
	return 

#parsing

parser = argparse.ArgumentParser()
parser.add_argument("file_name", type=str, help="name of the file")
parser.add_argument("min_reads", type=int, help="minimum number of reads in the row")
parser.add_argument("-sp", "--species", help="deleating sp.", action = "store_true")
parser.add_argument("-sc", "--semicolon", help="delimiter is semicolon (default = comma)", action = "store_true")


args = parser.parse_args()

delim = ";" if args.semicolon else ","

unique_species = DictionaryUniqueSpecies(args.file_name, args.min_reads, delim)
species = CountSpeciesWithoutSP(unique_species) if args.species else CountSpecies(unique_species)
if (len(species) == 0):
	print ("You will create 0 files (check -sc to modify the delimiter)")
else:
	print ("You will create %s files" %(len(species)))


proceed = True if input("Do you want to proceed? Type y/n") in ["y", "Y"] else False

if proceed:

    # Create target Directory
    dirName = "results"
    try:
    	os.mkdir(dirName)
    	print("Directory " , dirName ,  " Created ") 
    except FileExistsError:
    	print("Directory " , dirName ,  " already exists")
    
    # creating the files
    for sp in species:
    	create_file(args.file_name, dirName, sp, args.min_reads, delim)
