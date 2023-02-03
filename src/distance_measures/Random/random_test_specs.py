#how to run: python random_test_specs.py dir_name

import os
import random
import sys
from csv import writer
import datetime

def append_list_as_row(file_name, list_of_elem):
    with open(file_name, 'a+',newline='') as write_obj:
        csv_writer = writer(write_obj)
        csv_writer.writerow(list_of_elem)


count = 1
for i in range(10):
    begin_time = datetime.datetime.now()
    tc_files=[]
    rankedfile = 'randomfiles/Random_'+str(count)+'.csv'
    if os.path.exists(rankedfile):
      os.remove(rankedfile)
    header = ["File","Rank_maximean"]
    append_list_as_row(rankedfile, header)
    if len(sys.argv) != 2:
      print("Usage:", sys.argv[0], "/path/directory")
    else:
      dir_name=sys.argv[1]
      if os.path.isdir(dir_name):
        for file_name in os.listdir(dir_name):
          tc_files.append(file_name)
      else:
        print("Directory", dir_name, "does not exist")
        sys.exit(1)
    # shuffle test cases
    random.shuffle(tc_files)


    i=1
    for item in tc_files:
        row = [item, i]
        i=i+1
        append_list_as_row(rankedfile, row)
    count= count+1
    print( datetime.datetime.now() - begin_time)
