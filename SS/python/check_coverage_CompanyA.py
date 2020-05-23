#generate TC_no., sorted_rank, cumulative_new_features csv.
import csv
from collections import OrderedDict
import operator
import sys
from csv import reader
import pandas as pd
from csv import writer
import os

#variables
gen_file = "coverage_plot/all_techs.csv" #the generated file
# rankedfile = "ranking/random_test_specs_rank.csv"
FOLDER = "ranking"
mapped_features = 'coverage_info.csv'


def append_list_as_row(file_name, list_of_elem):
    with open(file_name, 'a+',newline='') as write_obj:
        csv_writer = writer(write_obj)
        csv_writer.writerow(list_of_elem)
#ensure a new file
if os.path.exists(gen_file):
    os.remove(gen_file)
header = ['Technique', 'File', 'Rank_maximean', 'Total_Failures']
append_list_as_row(gen_file, header)
for root, dirs, files in os.walk(FOLDER):
    for filename in files:
        #Combining two csv.s into one, to map test cases to their features
        colnames1 = ['tc_name', 'rank']
        df1 = pd.read_csv(FOLDER+"/"+filename, names=colnames1)
        colnames2 = ['tc_name', 'feature']
        df2 = pd.read_csv(mapped_features, names=colnames2)

        df = df1.merge(df2, on='tc_name', how='left')
        df.to_csv('merged.csv')

        #sort the resulted combined csv by rank
        reader = csv.reader(open("merged.csv"), delimiter=",")
        next(reader, None)  # skip the headers
        next(reader, None)  # skip the headers

        sortedlist = sorted(reader, key=lambda row: int(row[2]), reverse=False)

        #getting cumulative number of new features
        df = df[df.tc_name != 'File']
        column = df.feature.fillna(0)

        visited = set()
        count=0

        nofeat = 0
        i = 0
        for feature in column:
            for id in str(feature).replace("[","").replace("]","").split():

                if id not in visited:
                    visited.add(id)
                    # new feature here!
                    count = count +1
            i=i+1
            name = df.tc_name[i]
            row_content = [filename.replace(".csv", ""), name, i, count]
            append_list_as_row(gen_file, row_content)
