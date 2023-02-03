targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
    project="$(echo $targetdir | awk '{arrlength = split ($0, array, /\//); print array[arrlength - 1]}')"
fi

for d in $targetdir*/
do
  fileincrement=0;
  currentversion="$(echo $d | awk '{arrlength = split ($0, array, /\//); print array[arrlength - 1]}')"

  for f in $d*.txt
  do
    fileincrement=$(($fileincrement+1));
  done
  echo $currentversion","$fileincrement >> "methcount/"$project"_methcount.csv"

done
