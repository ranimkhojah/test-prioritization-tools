#!/bin/bash

# to run: cat <whatever you need to separate> | separatemethods.sh

# Any subsequent command which fail will cause the shell script to exit
# immediately
set -e

# \{ escapes character, [^] = not start of string, \} is pattern to stop at, + is one or more greedy
# grep -oP '\{[^\}]*'

# p for print, -n for quiet
# sed -n '\@Test\p'
# \1 is a 'Remember pattern' that remembers everything that is within \(.*\) so from xxx up to yyy but not yyy
# sed -n '/ @Test/, /\}/ p'


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


awk '
BEGIN {
    methnum = 0;
}
/@Test/ {
  flag=1; testpassed = 0; testlineprinted = 0;
    obrackets = 0; cbrackets = 0; printf "\n"; methnum++
  if (flaky == 1 && flakycount == 1) {
    flakycount = 0;
    printf "flakycount down   "
  }

  else if (flaky == 1 && flakycount == 0) {
    flaky = 0;
    printf "flaky down   "
  }
}

{ if (flag == 1) {
    obracksubstring = $0
    while (match(obracksubstring,/\{/)) {
      obracksubstring = substr(obracksubstring,RSTART+RLENGTH);
      obrackets++;
      printf "Ob: %d ", obrackets
    }
  }
}

{ if (flag == 1) {
    cbracksubstring = $0
    while (match(cbracksubstring,/\}/)) {
      cbracksubstring = substr(cbracksubstring,RSTART+RLENGTH);
      cbrackets++;
      printf "Cb: %d ", cbrackets
    }
  }
}

/Defects4J: flaky method/ {flaky = 1; flakycount = 1; flag = 0;}
"\/\/" {if (flaky == 1)
  flag = 0
}

/public/ || /protected/ || /private/ { if (flag == 1 && testpassed == 0) {
  testpassed = 1;
  methname = $3;
  print " Name: ", methname
  }
}

{ if (flag == 1 && testpassed == 0)
  testline = $0;
}

{ if (flag == 1 && testpassed == 1 && testlineprinted == 0) {
  print testline > methname ".txt";
  print testline " printed";
  testlineprinted = 1;
  }
}
{ if (flag == 1 && testpassed == 1 && testlineprinted == 1) {
    print $0 > methname ".txt";
  }
}

/\}/ {if (obrackets == cbrackets) {flag = 0; print "Matched brackets! "; obrackets = 0; cbrackets = 0; close(methname ".txt")} }

END{print "\n Open brackets: ", obrackets, "  Closed brackets: ", cbrackets, "  Total test methods: ", methnum}
'
