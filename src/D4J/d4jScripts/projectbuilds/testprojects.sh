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
  echo $d;
  defects4j test -w $d

done
