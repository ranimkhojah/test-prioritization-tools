# ! /usr/bin/awk -f
# find ./ -type f | xargs tail -n +1 | methodlist.sh

# Any subsequent command which fail will cause the shell script to exit
# immediately
# set -e



BEGIN {
    prevmethnum = 0;
    methnum = 0;
    # print "FILENAME: " ARGV[1];
    projectversion = ARGV[1];

    print "Processing file: " projectversion;
    arrlength = split (projectversion, array, /\// );
    # get last index value
    projectversion = array[arrlength];
    print "removed folder slashes: " projectversion;


    split (projectversion, array, /\_/ );
    projectversion = array[1];
    print " Version: " projectversion;
}

{ split($0, array, /\(/ );
  methodname = array[1];
  # print methodname;

  # print " [2] " array[2];

  classname = substr(array[2], 1, length(array[2]) - 1);
  # print classname;

  classandmethod = classname "." methodname;
  # print classandmethod;
  # print projectversion;

  print classandmethod > "reorganizedMeths/" projectversion "_methods.txt";
  methnum++;

}

END {
  print "Total test methods: ", methnum;
  print "target: " "reorganizedMeths/" projectversion "_methods.txt"
}
