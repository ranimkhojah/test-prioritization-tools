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
  # echo "      Now in $d    ";
  currentversion=$(echo $d | cut -d "/" -f 4);
  echo "      Now in $d, version $currentversion";
  (time docker run -it -v "$PWD":/data robertfeldt/mdist mdist --file-extensions "txt" -d ncd divseq --order maximean "$d")  &>> $currentversion"_NCD_ExecTime.txt";
done
