dir1="./"

echo "Total Args:" $#
args=("$@");

if (($# == 2))
  then
    # sorted, tech col added, ranked, total failures/faults csv 
    dir1=${args[0]}
    echo "targetdir 1: $dir1";

    dir2=${args[1]}
    echo "targetdir 2 = " $dir2;

    dir3="none"
    echo "targetdir 3 " $dir3;
fi



if (($# == 3))
  then
    # sorted, tech col added, ranked, total failures/faults csv
    dir1=${args[0]}
    echo "targetdir 1: $dir1";

    dir2=${args[1]}
    echo "targetdir 2: " $dir2;

    dir3=${args[2]}
    echo "targetdir 3: " $dir3;


fi

if (($# == 4))
  then
    # sorted, tech col added, ranked, total failures/faults csv
    dir1=${args[0]}
    echo "targetdir 1: $dir1";

    dir2=${args[1]}
    echo "targetdir 2: " $dir2;

    dir3=${args[2]}
    echo "targetdir 3: " $dir3;

    dir4=${args[3]}
    echo "targetdir 4: " $dir4;
fi



fileincrement=0;
# dir1 is the master, dir2 and dir3 are slaves
# thus, project folders must be exactly the same
for f1 in $dir1*.csv
do
  fileincrement=$(($fileincrement+1));
  # echo "      master: $f1  ";
  currentfile1="$(echo $f1 | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  currentversion1="$(echo $currentfile1 | awk -F "_" '{print $1}')"
  currenttechnique1="$(echo $f1 | awk -F "_" '{print $2}')"
  failorfault1="$(echo $currentfile1 | awk -F "_" '{print $4}')"
  echo "MASTER file : $currentfile1,  version: $currentversion1,  technique: $currenttechnique1";

  cat $f1 > $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv";

  for f2 in $dir2*.csv
  do
    currentfile2="$(echo $f2 | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
    currentversion2="$(echo $currentfile2 | awk -F "_" '{print $1}')"
    currenttechnique2="$(echo $f2 | awk -F "_" '{print $2}')"
    failorfault2="$(echo $currentfile2 | awk -F "_" '{print $4}')"
    if [[ "$currentversion2" == "$currentversion1" ]];
      then
        echo "  slave file : $currentfile2,  version: $currentversion2,  technique: $currenttechnique2";
        # print from line 2

        echo '' >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
        tail --lines=+2 $f2 >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
    fi
  done

  if (($# >= 3))
    then
    # echo "dir3 exists";

    for f3 in $dir3*.csv
    do
      currentfile3="$(echo $f3 | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
      currentversion3="$(echo $currentfile3 | awk -F "_" '{print $1}')"
      currenttechnique3="$(echo $f3 | awk -F "_" '{print $2}')"
      failorfault3="$(echo $currentfile3 | awk -F "_" '{print $4}')"
      if [[ "$currentversion3" == "$currentversion1" ]];
        then
        echo "   slave  2 : $currentfile3,  version: $currentversion3,  technique: $currenttechnique3";
        echo '' >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
        tail --lines=+2 $f3 >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
      fi
    done

    if (($# == 4))
      then
      # echo "dir4 exists";

      for f4 in $dir4*.csv
      do
        currentfile4="$(echo $f4 | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
        currentversion4="$(echo $currentfile4 | awk -F "_" '{print $1}')"
        currenttechnique4="$(echo $f4 | awk -F "_" '{print $2}')"
        failorfault4="$(echo $currentfile4 | awk -F "_" '{print $4}')"
        if [[ "$currentversion4" == "$currentversion1" ]];
          then
          echo "   slave  3 : $currentfile4,  version: $currentversion4,  technique: $currenttechnique4";
          echo '' >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
          tail --lines=+2 $f4 >> $currentversion1"_merged_"$failorfault1"_"$fileincrement".csv"
        fi
      done
    fi

  fi

done
