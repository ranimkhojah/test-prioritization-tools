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
    currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
    currentproject="$(echo $currentfile | awk -F "_" '{print $1}')";
    echo "project -> $currentproject";
    # g for global, required for replacing all occurances
    sed -e 's/::/./g' $f > $currentproject"_nocolon_triggers.csv";
done
