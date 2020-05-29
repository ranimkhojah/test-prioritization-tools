targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

for d in $targetdir*/
do
  increment=1
  currentversion=$(echo $d | cut -d "/" -f 4);
  echo "      Now in $d, version $currentversion";

  while [ $increment -le 100 ]
  do
    echo $increment >> $currentversion"_Random_ExecTime.txt";
    (time python3 ./random_test_specs.py "$d" "$increment") &>> $currentversion"_Random_ExecTime.txt";
    increment=$(($increment+1));
  done
done

dos2unix ./rankedtests/*.csv
