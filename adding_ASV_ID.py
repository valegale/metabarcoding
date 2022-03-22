import argparse
import csv
import os

def create_ASV_file(file_name):
	file_name_ASV = "Data/%s_ASV.csv"%os.path.basename(file_name).split('.')[0]
	num_lines = sum(1 for line in open(file_name)) - 1 
	new_file = open(file_name_ASV, "w", newline='')
	with open(file_name) as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=delim)
		csv_writer = csv.writer(new_file, delimiter=delim)

		header = next(csv_reader) 
		header.insert(1, "ASV_ID")
		csv_writer.writerow(header)
		i = 1 
		
		for row in csv_reader:
			ASV_num = "ASV_" + "".join(["0" for _ in range(len(str(num_lines)) - len(str(i)))]) + str(i)
			row.insert(1, ASV_num)
			csv_writer.writerow(row)
			i += 1

#parsing
parser = argparse.ArgumentParser()
parser.add_argument("file_name", type=str, help="name of the file")
parser.add_argument("-sc", "--semicolon", help="delimiter is semicolon (default = comma)", action = "store_true")

args = parser.parse_args()

delim = ";" if args.semicolon else ","
create_ASV_file(args.file_name)

