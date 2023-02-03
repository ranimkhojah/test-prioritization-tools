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
  currenttechnique="$(echo $f | awk -F "_" '{print $2}')"
  echo "file : $currentfile,  technique: $currenttechnique";
  awk '
  BEGIN {
    FS = ",";
    arrlength = split (ARGV[1], array, /\//);
    currentfile = array[arrlength];
    filearrlength = split (currentfile, filearray, /.csv/);
    currentfilename = filearray[1];
    print "     Filename: " currentfilename;

    splitfilenamelength = split(currentfilename, namearray, /_/);
    currentversion = namearray[1];
    merged = namearray[2];
    faultorfailure = namearray[3];
    increment = namearray[4];
  }

  {
    if (FNR == 1) {
      print $0 > currentversion "_shortened" merged "_" faultorfailure "_" increment ".csv";
    }
  }
  {
    if (FNR != 1) {
      testmetharrlength = split($2, testmetharr, /\//);
      testmethod = testmetharr[testmetharrlength];
      # printf FNR " - ";
      print $1 "," testmethod "," $3 "," $4 >> currentversion "_shortened" merged "_" faultorfailure "_" increment ".csv";
    }
  }
  ' $f


done
