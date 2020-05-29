targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

project="$(echo $targetdir | awk '{arrlength = split ($0, array, /\//); print array[4]}')"
tech="$(echo $targetdir | awk '{arrlength = split ($0, array, /\//); print array[arrlength-1]}')"
# echo "Version,Minutes,Seconds" > $project"_"$tech"_mergedexectime.csv";
echo "Version,TotalSeconds" > $project"_"$tech"_mergedexectime.csv";
for f in $targetdir*.txt
do
  totalsecs=0;
  currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  currentversion="$(echo $currentfile | awk '{arrlength = split ($0, array, /_/); print array[1]}')"
  echo $currentfile "," $currentversion", "$project", "$tech;
  row=$(tail -3 $f | head -1);
  # echo $row;

  time=$(echo $row | awk '{arrlength = split ($0, array, / /); print array[arrlength]}')
  # echo $time;

  mins=$(echo $time | awk '{arrlength = split ($0, array, /m/); print array[1]}')
  secs=$(echo $time | awk '{arrlength = split ($0, array, /m/); print array[arrlength]}')
  onlysecs=$(echo $secs | awk '{arrlength = split ($0, array, /s/); print array[1]}')
  millisecs=$(echo $onlysecs | awk '{arrlength = split ($0, array, /\./); print array[2]}')
  atomicsecs=$(echo $onlysecs | awk '{arrlength = split ($0, array, /\./); print array[1]}')
  totalsecs=$onlysecs;

  # echo $onlysecs;
  # echo $atomicsecs;

  if (($mins > 0))
    then
      convertedmins=$(($mins*60));
      echo $convertedmins "+" $onlysecs;
      totalsecs=$(echo $onlysecs"+"$convertedmins | bc);
      # echo $totalsecs;

  fi
  if (($mins == 0))
    then
      echo $totalsecs;
  fi


  echo $currentversion","$totalsecs >> $project"_"$tech"_mergedexectime.csv";
done
