targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

# only works for sorted csv due to naming - <project>_<technique>_sorted

for f in $targetdir*.csv
do
  echo "      shifting $f  ";
  currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  currenttechnique="$(echo $f | awk -F "_" '{print $2}')"
  echo "file : $currentfile,  technique: $currenttechnique";
  if [[ "$currenttechnique" == "Jaccard" ]];
    then
      echo "tech is Jacc"
    sed -i -e '1s/^/Technique,/' $f;
    sed -i -e '2,$s/^/Jaccard,/' $f;
  fi
  if [[ "$currenttechnique" == "NCD" ]];
    then
      echo "tech is NCD"
      sed -i -e '1s/^/Technique,/' $f;
      sed -i -e '2,$s/^/NCD,/' $f;
    # awk 'NR=1 {}'
  fi
  if [[ "$currenttechnique" == "Levenshtein" ]];
    then
      echo "tech is Levenshtein"
      sed -i -e '1s/^/Technique,/' $f;
      sed -i -e '2,$s/^/Levenshtein,/' $f;
    # awk 'NR=1 {}'
  fi
  if [[ "$currenttechnique" == "random" ]];
    then
      echo "tech is Random"
      sed -i -e '1s/^/Technique,/' $f;
      sed -i -e '2,$s/^/Random,/' $f;
    # awk 'NR=1 {}'
  fi
done
