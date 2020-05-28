#!/bin/bash

# to run: cat <whatever you need to separate> | separatemethods.sh

# for recursive cat:
# find . -wholename ./lang/1/lang3/'*.java' -exec cat {} \;  | ./separatemethods.sh

# to cat with filename:
# find ./ -type f | xargs tail -n +1 | separatemethods.sh

# Any subsequent command which fail will cause the shell script to exit
# immediately
set -e

# print everything
# awk '{print $0}'

# output to text file with incrementing numbers
# { if (flag == 1)
#   print $0 >> methnum ".txt"
# }

# find multiple patterns on the same line
# { while
#   (match($0,/\}/)) {
#     print substr($0, RSTART,RLENGTH); $0=substr($0,RSTART+RLENGTH)
#   }
# }

# count number of brackets to know when method ends
# /\{/ {if (flag == 1)
#   obrackets++;
#   printf "obrackets: %d ", obrackets;
# }
# /\}/ {if (flag == 1)
  # cbrackets++;
  # printf "cbrackets: %d ", cbrackets;
# }

# output complete method only when we know method name - remember 1 line before
# { if (flag == 1 && testpassed == 1 && testlineprinted == 0) {
#   print testline > methname ".txt";
#   print "@test printed";
#   testlineprinted = 1;
#   }
# }
# { if (flag == 1 && testpassed == 1 && testlineprinted == 1) {
#     print $0 > methname ".txt"
#   }
# }

# ignore flaky tests
# /Defects4J: flaky method/ {flaky = 1; flakycount = 1; flag = 0;}
# "\/\/" {if (flaky == 1)
#   flag = 0
# }

# original /test/
# flag=1; testpassed = 0; testlineprinted = 0;
#   obrackets = 0; cbrackets = 0; printf "\n"; methnum++
# if (flaky == 1 && flakycount == 1) {
#   flakycount = 0;
#   printf "flakycount down   "
# }
#
# else if (flaky == 1 && flakycount == 0) {
#   flaky = 0;
#   printf "flaky down   "
# }

# if (flag == 1) {
#   methname = $3;
#   print " Name: ", methname
# }

# { if (flag == 1 || possiblemethbeginfound == 1) {
#     stringsubstr = $0
#     while (match(stringsubstr, /\"/ )) {
#       print "string quote: " substr(stringsubstr, RSTART,RLENGTH);
#       stringsubstr = substr(stringsubstr,RSTART+RLENGTH);
#       quotes++;
#       instring = 1;
#       if (quotes % 2) {
#         quotes = 0;
#         instring = 0;
#         print "String Matched! "
#       }
#       printf " Oq: %d ", quotes
#     }
#   }
# }

# /\"/ { if (flag == 1 || possiblemethbeginfound == 1) {
#   quotes++;
#   instring = 1;
#   printf " Oq: %d ", quotes
#     if (quotes % 2) {
#       quotes = 0;
#       instring = 0;
#       print "String Matched! "
#     }
#   }
# }

# mkdir methresults;

awk '
BEGIN {
    methnum = 0;
    obrackets = 0;
    cbrackets = 0;
}

/\=\=\>/ {
  unpathedfile = $2;
  currentdir = substr($2, 1, 2);
  targetdir = currentdir "methresults/";
  gsub(/\//, "-", unpathedfile);


  filename = substr (unpathedfile, 3);
  filename = substr(filename, 1, length(filename) - 5);

  currentfile =  targetdir  filename;
  print "Current file: " currentfile
}

/@Test/ { testpassed = 0; testlineprinted = 0;
  print " @Test found"
}

/public/ || /protected/ || /private/ {
  if (obrackets == 0 && cbrackets == 0) {
    flag=0; testpassed = 1; possiblemethbeginfound = 1;
    obrackets = 0; cbrackets = 0; instring = 0; printf "\n";
  }

  if(obrackets > 0 || cbrackets > 0) {
    print "Still in a method"
    flag = 1; possiblemethbeginfound = 1; testpassed = 1;
  }

  if (flaky == 1 && flakycount == 1) {
    flakycount = 0;
    printf "flakycount down   "
  }
  else if (flaky == 1 && flakycount == 0) {
    flaky = 0;
    printf "flaky down   "
  }
  if ($2 == "class" || $3 == "class" || $4 == "class") {
    possiblemethbeginfound = 0;
    flag = 0;
    testpassed = 0;
    print "Class begin found";
  }
}

{ if (flag == 0 && possiblemethbeginfound == 1) {
    methsigsubstr = $0;
    while (match(methsigsubstr, /test[^ ]*/ )) {
      methname = substr(methsigsubstr, RSTART, RLENGTH);
      print " Signature: " methname;

      methsigsubstr = substr(methsigsubstr, RSTART+RLENGTH);
      flag = 1;
      methnum++
    }
  }
}


{ if (flag == 1 || possiblemethbeginfound == 1) {
    obracksubstring = $0;
    cbracksubstring = $0;
    stringsubstr = $0;

    if (match(stringsubstr, /\"/ )) {
      substr(stringsubstr, RSTART,RLENGTH);
      stringsubstr = substr(stringsubstr,RSTART+RLENGTH);
      quotes++;
      instring = 1;
    }

    if (match(obracksubstring, /\{/ ) != 0) {
      if (instring == 1) {
        print " !! { OB in string  "
      }
      if (instring == 0) {
        obracksubstring = substr(obracksubstring,RSTART+RLENGTH);
        obrackets++;
        printf "Ob: %d ", obrackets
        if (match(obracksubstring, /\{/ ) != 0) {
          obracksubstring = substr(obracksubstring,RSTART+RLENGTH);
          obrackets++;
          printf "Ob: %d ", obrackets
        }
      }
    }

    if (match(cbracksubstring, /\}/ ) != 0) {
      if (instring == 1) {
        print "  CB in string } !! "
      }
      if (instring == 0) {
        cbracksubstring = substr(cbracksubstring,RSTART+RLENGTH);
        cbrackets++;
        printf "Cb: %d ", cbrackets
        if (match(cbracksubstring, /\}/ ) != 0) {
          cbracksubstring = substr(cbracksubstring,RSTART+RLENGTH);
          cbrackets++;
          printf "Cb: %d ", cbrackets
        }
      }
    }

    if (quotes % 2) {
      quotes = 0;
      instring = 0;
      print "String Matched! "
    }
  }
}

# { if (flag == 1 || possiblemethbeginfound == 1 ) {
#     cbracksubstring = $0
#     while (match(cbracksubstring, /\}/ ) != 0) {
#       if (instring == 0) {
#         cbracksubstring = substr(cbracksubstring,RSTART+RLENGTH);
#         cbrackets++;
#         printf "Cb: %d ", cbrackets
#       }
#     }
#   }
# }


/Defects4J: flaky method/ {flaky = 1; flakycount = 1; flag = 0;}
"\/\/" {if (flaky == 1)
  flag = 0
}


{ if (flag == 1 && testpassed == 0)
  testline = $0;
}

{ if (flag == 1 && testpassed == 1 && testlineprinted == 0) {
  print "testline: " testline;
  testlineprinted = 1;
  }
}
{ if (flag == 1 && testpassed == 1) {
    print $0 >  currentfile "-" methname ".txt";
  }
}

/\}/ {
  if (obrackets == cbrackets) {
  flag = 0; print "Matched brackets! "; instring = 0; obrackets = 0; cbrackets = 0; possiblemethbeginfound = 0;
  close(  currentfile "-" methname ".txt")
  }
}

END{print "Open brackets: ", obrackets, "  Closed brackets: ", cbrackets, "  Total test methods: ", methnum}
'
