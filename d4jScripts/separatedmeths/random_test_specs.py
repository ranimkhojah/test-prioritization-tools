#how to run: python random_test_specs.py dir_name

import os
import random
import sys
from csv import writer

tc_files=[]
# rankedfile = 'rankedtests/random_test_specs_rank.csv'
if len(sys.argv) != 3:
  print("Usage:", sys.argv[0], "/path/directory")
else:
  dir_name=sys.argv[1]
  counter=sys.argv[2]
  if os.path.isdir(dir_name):
    for file_name in os.listdir(dir_name):
      tc_files.append(file_name)
  else:
    print("Directory", dir_name, "does not exist")
    sys.exit(1)


def append_list_as_row(file_name, list_of_elem):
    with open(file_name, 'a+',newline='') as write_obj:
        csv_writer = writer(write_obj)
        csv_writer.writerow(list_of_elem)

split_dirname = dir_name.split("/");
currentversion = split_dirname[3];
rankedfile = 'rankedtests/' + currentversion + '_random_test_rank.csv'

# if os.path.exists(rankedfile):
#   os.remove(rankedfile)
# print(counter)
if str(counter) == "1":
    # print("File start")
    startrow = ["Counter","File", "Rank" ]
    with open(rankedfile, 'a+',newline='') as write_obj:
        csv_writer = writer(write_obj)
        csv_writer.writerow(startrow)


def randomize(tc_files, counter):
    # shuffle test cases
    random.shuffle(tc_files)

    i=1
    # i=2
    for item in tc_files:
        row = ["Random_" + str(counter), item, i]
        i=i+1
        append_list_as_row(rankedfile, row)

randomize(tc_files, counter);

# def runtentimes(tc_files):
#     increment = 1
#
#     while increment <= 10:
#         print(increment)
#         randomize(tc_files, increment)
#         increment = increment + 1
