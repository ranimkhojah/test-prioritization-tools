# renames each all_tests file in each project buggy version.
# execute this script on the parent folder.
# parent
# |
# |-bug1
# |-bug2

targetdir="."

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

find $targetdir -maxdepth 2 -name "all_tests" |
rename 's:(^|.*/)([^/]*)/([^/]*)$:methlist/$2_$3.txt:'
