# 2 brackets to run the command in a subshell
projectver=1
end=1;
echo "Total Args:" $#
args=("$@");
fixed="f"
currentfolder="/media/sf_Bachelor_Thesis/d4jprojects/d4jprojectbuilds/fixed/"
slash="/"

if (($# == 3))
  then
# projectname
echo "name = " ${args[0]}
projname=${args[0]}
# startingver
echo "ver = " ${args[1]}
projectver=${args[1]}
# ending
echo "end = " ${args[2]}
end=${args[2]}
fi



while (($projectver <= $end))
  do
    echo $projectver;
    echo "Project: " $projname;
    echo "Version: " $projectver$fixed;
    echo "Folder -- " $currentfolder$projname$slash$projname$projectver
    defects4j checkout -p $projname -v $projectver$fixed -w $currentfolder$projname$slash$projname$projectver
    projectver=$(( projectver+1 ));
done
