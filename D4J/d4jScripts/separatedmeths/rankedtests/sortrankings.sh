targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

for f in $targetdir*.csv
do
  # echo "      sorting $f  ";
  # uses 2nd row in csv to know version
  currentversion="$(sed "2q;d" $f | awk -F "/" '{print $4}')";
  currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  # takes filename and prints third section
  currenttechnique="$(echo $f | awk -F "_" '{print $3}')"
  echo "file : $currentfile,  version: $currentversion";
  # sort with comma, based on second column
  sort --field-separator=',' -k 2n $f > $currentversion"_"$currenttechnique"_sorted.csv";

done
