targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 1))
  then
    echo "targetdir = " ${args[0]}
    targetdir=${args[0]}
fi

for f in $targetdir*
do
  echo "reorganizing " $f;
  awk -f ./methodlist.awk $f;
done
