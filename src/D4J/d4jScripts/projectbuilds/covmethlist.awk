


# requires rawprojectmeths



BEGIN {
  prevmethnum = 0;
  methnum = 0;

  projectversion = ARGV[1];
  print "Processing file: " projectversion;

  arrlength = split (projectversion, array, /\// );
  projectversion = array[arrlength];
  print "removed folder slashes: " projectversion;

  split (projectversion, array, /\_/ );
  projectversion = array[1];
  print " Version: " projectversion;
}

{
  split($0, array, /\(/ );
  methodname = array[1];

  classname = substr(array[2], 1, length(array[2]) - 1);
  classandmethod = classname "::" methodname;

  print classandmethod > "reorganizedCovMeths/" projectversion "_covmethods.txt";
  methnum++;
}

END {
  print "Total test methods: ", methnum;
  print "target: " "reorganizedCovMeths/" projectversion "_covmethods.txt"
}
