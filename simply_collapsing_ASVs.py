import argparse
import csv
import os
import numpy as np

def writing_collapsed_file(file_name):

	unique_species = {}
	taxonomy = {}
	with open(file_name) as csv_file:
		    csv_reader = csv.reader(csv_file, delimiter=',')
		    header = next(csv_reader) 
		    genus_species_index= len(header) - 1
		    index = 0
		    for row in csv_reader: 
		    	if row[genus_species_index] != "NA": 
			    	if row[genus_species_index] in unique_species:
			    		unique_species[row[genus_species_index]] = np.add(unique_species[row[genus_species_index]], np.array(row[1:genus_species_index - 7]).astype(int))
			    	else:
			    		unique_species[row[genus_species_index]] = np.array(row[1:genus_species_index - 7]).astype(int) #8 levels of taxonomy
			    		taxonomy[row[genus_species_index]] = row[genus_species_index - 7: genus_species_index]
	    		else: #simply keeping track of NA rows, for ordering them later from the most abundant to the least abundant
			    	unique_species["NA_species" + str(index)] = np.array(row[1:genus_species_index - 7]).astype(int)
		    		taxonomy["NA_species" + str(index)] = row[genus_species_index - 7: genus_species_index]
		    		index += 1

	order_species = sorted(unique_species.keys(), key=lambda k: sum(unique_species[k]), reverse=True)

	#writing file
	newfile_name = "results/%s_collapsed.csv"%os.path.basename(file_name).split('.')[0]
	new_file = open(newfile_name, "w", newline='')
	csv_writer = csv.writer(new_file)
	csv_writer.writerow(header[1:-1] + ["Taxon"]) # header without fragment, plus Taxon as a last value

	for species in order_species:
		name = species if species[:2] != "NA" else "NA"
		new_row = list(unique_species[species]) + taxonomy[species] + [name]
		csv_writer.writerow(new_row)


parser = argparse.ArgumentParser()
parser.add_argument("file_name", type=str, help="name of the file")

args = parser.parse_args()

writing_collapsed_file(args.file_name)