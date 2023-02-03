targetdir="./"

echo "Total Args:" $#
args=("$@");

# requires project dir and covprojectmethod dir
if (($# == 2))
  then
    targetdir=${args[0]}
    echo "targetdir = " $targetdir

    covmethdir=${args[1]}
    echo "covmeths - " $covmethdir
fi

for d in $targetdir*/
do
  currentdir="$(echo $d | awk '{arrlength = split ($0, array, /\//); print array[arrlength - 1]}')"

  # match correct methodfile
  for f in $covmethdir*
  do
    covmethfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
    covmethversion="$(echo $covmethfile | awk -F "_" '{print $1}')"

    if [[ "$covmethversion" == "$currentdir" ]];
    then
      correctcovmethver=$covmethversion
      correctcovfile=$f
      break
    fi

  done

  echo " ==== "$currentdir","$correctcovmethver","$correctcovfile;
  # (
  # xargs -a $correctcovfile -n 1 -I method -t defects4j coverage -w $d -t method
  # ) &> $correctcovmethver".txt"
  mkdir "projectcoverage/"$currentdir
  while IFS='' read -r LINE || [ -n "${LINE}" ];
  do
    outputfilename="$(echo $LINE | awk '{arrlength = split ($0, array, /::/); print array[1]"."array[arrlength]}')"
    echo $outputfilename
    echo "PROCESSING: defects4j coverage -w $d -t ${LINE}"
    echo $LINE > "projectcoverage/"$currentdir"/"$currentdir"_"$outputfilename".txt"
    defects4j coverage -w $d -t $LINE >> "projectcoverage/"$currentdir"/"$currentdir"_"$outputfilename".txt"
  done < $correctcovfile



done
