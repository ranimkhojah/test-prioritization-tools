# for d in ./*/;
#
# do (cd "$d" &&
# (^|.*/)
find . -maxdepth 2 -name "all_tests" |
rename 's:(^|.*/)([^/]*)/([^/]*)$:methlist/$2_$3.txt:'

# );
# done

# printf '%s\n' "${PWD##*/}"
# to print current dir to stdout

# && rename '
# s/^//' all_tests "$@"
# fname=${file##*/} #This gives your base filename.
# fpath=${file%/*} # Your dir
# dname=${${PWD##*/}} # dir name

# mv $file ${fpath}/${dname}${fname}

# FNAME=$(basename ${i})
# FPATH=$(dirname ${i})
# DNAME=${basename ${FNAME})
# mv ${i} ${FPATH}/${DNAME}.${FNAME}

# find . -name "all_tests"

# find . -type f -name 'all_tests' -exec mv {} {}_renamed \;
