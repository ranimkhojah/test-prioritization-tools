targetdir="./"

echo "Total Args:" $#
args=("$@");

if (($# == 3))
  then
    # sorted, tech col added ranked csv
    triggerfile=${args[0]}
    echo "triggerfile: $triggerfile";

    targetdir=${args[1]}
    echo "targetdir = " $targetdir;

    projectid=${args[2]}
    echo "project: " $projectid;

fi

fileincrement=0;

for f in $targetdir*.csv
do
  fileincrement=$(($fileincrement+1));
  # currentfile="$(echo $f | awk '{arrlength = split ($0, array, /\//); print array[arrlength]}')"
  awk -v projectname=$projectid -v filenameincrement=$fileincrement ' BEGIN {
    FS = ",";
    # print " File: " ARGV[2];
    arrlength = split (ARGV[2], array, /\//);
    currentfile = array[arrlength];
    printf " \n Current File: " currentfile;

    filearrlength = split (currentfile, filearray, /.csv/);
    currentfilename = filearray[1];
    print "     Filename: " currentfilename;

    printf " Project name: " projectname;
    arr2length = split (currentfile, arr2, /_/);

    fullprojver = arr2[0];
    curfilearrlength = split (arr2[1], curfilearr, projectname);

    projver=curfilearr[curfilearrlength];
    printf "    File Project version: " projver;

    methlistarrlength = 0;
    faults = 0;
    cappedfaults = 0;
    failures = 0;
  }

# inside trigger file
  FNR==NR {
      vertriggermeths[NR] = $0;
      # print vertriggermeths[NR];
      # currentversionnum = 0;
      curvernumlength = split (vertriggermeths[NR], curvernumarr, /,/ );
      currentversionnum = curvernumarr[1];

      methodarrlength = split (vertriggermeths[NR], methodarr, /"/ );
      methods = methodarr[2];

      methlistarrlength = split (methods, methlistarr, /;/ );

      { if (projver == currentversionnum) {
        print "   --- version: " currentversionnum ;
        # print "===> " methods;
        # print "==>> " vertriggermeths[NR] "   (sanity check) ";
        triggerslength = methlistarrlength;
        { for (i = 1; i <= methlistarrlength; i++) {
          triggers[i] = methlistarr[i];
          print " TRIGGER " i ": " triggers[i];
          }
        }
        }
      }
    # next;
  }

  # { for (i = 1; i <= methlistarrlength; i++) {
  #   print " TRIGGER " i ": " methlistarr[i];
  #   }
  # }

# inside rankings
  NR!=FNR {

    if (FNR == 1) {printf $0 ",Total_Failures" > "./rankedtotalfailures/" currentfilename "_totalfailures_" filenameincrement ".csv";}
    if (FNR != 1) {
      # print FNR "   --   ";
      printf "\n" $0 >> "./rankedtotalfailures/" currentfilename "_totalfailures_" filenameincrement ".csv";

      rankmethodarrlength = split ($0, rankmethodarr, /,/ );
      rankmethod = rankmethodarr[2];
      ranking = rankmethodarr[rankmethodarrlength];


      shortrankmetharrlength = split (rankmethod, shortrankmetharr, /\//);
      currentrankmeth = shortrankmetharr[shortrankmetharrlength];

      actualrankmetharrlength = split (currentrankmeth, actualrankmetharr, /.txt/);
      actualrankmeth = actualrankmetharr[1];

      # printf actualrankmeth "   --   ";
      # print ranking;

      { for (i = 1; i <= triggerslength; i++) {
          # printf "\n"  actualrankmeth "   --   ";

          if (actualrankmeth == triggers[i]) {
            faults++;
            cappedfaults++;
            failures++;
            foundtriggersarr[faults] = actualrankmeth;

            # printf ">>>>>> " actualrankmeth;
            # print "  -- " ranking;
            # print  "TRIG LENGTH: " triggerslength;
          }

          if (actualrankmeth != triggers[i]) {
            # printf "," failures;
          }
        }
      }
      # if (failures > 1) {
      #   print "\n ONLY 1 BUG"
      #   cappedfaults = 1;
      # }
      printf "," failures >> "./rankedtotalfailures/" currentfilename "_totalfailures_" filenameincrement ".csv";

    }
  }

  END {
    if (failures < triggerslength && failures > 0) {
      print "==============  INHERITED TESTS EXIST - Found Failures: " failures " ==============";
      print currentfile " - Found Failures: " failures >> "./rankedtotalfailures/" projectname "_totalfailures_log.txt";
      for (i = 1; i < faults + 1; i++) {
        print i " -> " foundtriggersarr[i];
        print i " -> " foundtriggersarr[i] >> "./rankedtotalfailures/" projectname "_totalfailures_log.txt";
      }
    }
    if (failures == triggerslength) {
      print "ALL TRIGGERS MATCHED";
    }
    if (failures == 0) {
      print ">>>>>>>>>>>>> NO TRIGGERS FOUND <<<<<<<<<<<<<<";
      print currentfile "     >>>>>>>> NO TRIGGERS FOUND" >> "./rankedtotalfailures/" projectname "_totalfailures_log.txt"
    }
  }
' $triggerfile $f

done
