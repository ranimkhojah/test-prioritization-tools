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
# echo "Version,1_Secs,2_Secs,3_Secs,4_Secs,5_Secs,6_Secs,7_Secs,8_Secs,9_Secs,10_Secs" > $project"_"$tech"_mergedexectime.csv";

for f in $targetdir*.txt
do
  currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  currentversion="$(echo $currentfile | awk '{arrlength = split ($0, array, /_/); print array[1]}')"
  echo $currentfile "," $currentversion", "$project", "$tech;

  # row=$();
  cat $f | awk -v project=$project -v tech=$tech -v currentversion=$currentversion ' BEGIN {
    counter = 1;
    print project ", " tech;
    totalrow = "";
  }
  /real/ {
    row = $0;
    # print counter "-- " $0;

    # timelength = split (row, timearray, /l/);
    # time = timearray[timelength];
    time = $2;
    # print "Time:"time;

    minlength = split (time, minarray, /m/);
    mins = minarray[1];

    secs = minarray[minlength];

    onlysecslength = split (secs, onlysecsarray, /s/)
    onlysecs = onlysecsarray[1];
    totalsecs = onlysecs;

    # print counter "--" mins "," secs "," onlysecs;
    # print counter "--" mins "," totalsecs;


    {
      if (mins > 0) {
        print "EXTREME HIGH TIME - MINS EXIST";
        convertedmins = mins * 60;
        print convertedmins;
        totalsecs = onlysecs + convertedmins;
      }
    }

    # print totalsecs;
    {
      if (totalrow == "") {
        totalrow = totalsecs;
      }
      else {
        totalrow = totalrow "," totalsecs ;
      }
    }

    counter++;
  }
  END {
    print totalrow;

    print currentversion","totalrow >> project"_"tech"_mergedexectime.csv";
  }
 '
  # echo $row;

  # time=$(echo $row | awk '{arrlength = split ($0, array, / /); print array[arrlength]}')
  # echo $time;
#
  # mins=$(echo $time | awk '{arrlength = split ($0, array, /m/); print array[1]}')
  # secs=$(echo $time | awk '{arrlength = split ($0, array, /m/); print array[arrlength]}')
  # onlysecs=$(echo $secs | awk '{arrlength = split ($0, array, /s/); print array[1]}')
#
#   echo $currentversion","$mins":"$onlysecs >> $project"_"$tech"_mergedexectime.csv";
done
