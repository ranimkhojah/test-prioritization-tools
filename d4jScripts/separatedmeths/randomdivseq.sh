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
  currentversion=$(echo $d | cut -d "/" -f 4);
  echo "      Now in $d, version $currentversion";
  (time python3 ./random_test_specs.py "$d") &>> $currentversion"_Random_ExecTime.txt";
done

dos2unix ./rankedtests/*.csv
