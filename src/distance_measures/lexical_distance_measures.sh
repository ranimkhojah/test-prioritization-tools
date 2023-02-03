#!/bin/bash
dis_measures=("jaccard" "levenshtein" "ncd")
for s in "${dis_measures[@]}"
do
    time docker run -it -v "$PWD":/data robertfeldt/mdist mdist -d $s distances mozilla_tests_text
done
