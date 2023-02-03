
import os
import csv
from csv import writer

features = []
FEATURES_FOLDER = "tested_features_id"
for root, dirs, files in os.walk(FEATURES_FOLDER):
    for filename in files:
        with open("tested_features_id/"+filename) as f:
            features.append(f.read())

def unique(list1):
    # insert the list to the set
    list_set = set(list1)
    # convert the set to the list
    unique_list = (list(list_set))
    return unique_list

def append_list_as_row(file_name, list_of_elem):
    # Open file in append mode
    with open(file_name, 'a+') as write_obj:
        # Create a writer object from csv module
        csv_writer = writer(write_obj)
        # Add contents of list as last row in the csv file
        csv_writer.writerow(list_of_elem)


for feature in unique(features):
    row = [feature, features.count(feature)]
    print(row)
    append_list_as_row("feat_occur.csv", row)
