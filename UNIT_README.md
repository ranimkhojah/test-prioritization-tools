# Lemon-Ginger-Thesis
## Unit level
#### Prerequisites
Defects4j needs to be set up first.
The scripts are shell scripts, and thus require bash.

### Defects4j Pipeline

1. Checkout all versions of a project with **checkoutallfixedversions.sh**
  - Accepts 3 parameters all 3 required
    - Project identifier to checkout
    - Starting bug version
    - Ending bug version
  - Must make parent directory first, needs to be labelled the same as project identifier
  - Versions will be inside that folder

2. Test each version with **testprojects.sh**
  - Takes 1 parameter, required
    - Target directory of where all the checked out versions are
  - Need to do this to get all_tests. If you know any other way hmu
3. Retrieve a list of method names with  **renamealltests.sh**
  - Takes 1 parameter, required
    - Target directory of where the parent directory is
      - Example: Lang > lang1, lang2, lang3
    - Lang is the parent directory
  - Folder called “methlist” must be created beforehand in the same place where renamealltests is
  - I should really rename this script to a better name
4. Restructure/reorganize the list with **reorgmethlist.sh**
  - Accepts 1 parameter, required
    - Target directory of where the extracted method name lists are
  - reorgmethlist.sh uses methodlist.awk
  - To run methodlist.awk itself, use awk file with “awk -f methodlist.awk [location of methodlist file]”. But why would you do that.
  - reorganizedMeths/ folder should already be created
5. Separate methods by running **felixMethSep**
  - Before running the tool:
    - Put all the restructured methodlists into target/surefire-reports
    - Copy all the respective checked out versions of corresponding projects to target/projects_to_separate. The entire projects. Yes. I dont know another way to identify specific projects easily.
  - Run the maven project. Its a maven project. I ran it in vscode so idk how to do it manually. Help me, help you.
  - The resulting code will be in target/pit-reports/code.
6. Rank the stuff.
  - Depending on technique, 3 choices:
    - **Jaccarddivseq.sh**, **levendivseq.sh**, **ncddivseq.sh**, **randomdivseq.sh**
    - Accepts 1 argument, required
      - Target directory where all directories of the extracted code is, 1 level deep.
  - Generates both the rankings and execution time, which is outputted into a different file of just the stdout
  - Randomdivseq generates the rankings in rankedtests/
7. Preprocess for Failures - sort rankings - **rankedtests/sortrankings.sh**
  - Ranking csv needs to be sorted in ascending order for easier processing
  - Accepts 1 argument, required - target directory where all rankings are stored
8. Preprocess - Add “technique” column,shift other columns right - **rankedtests/shiftcolright.sh**
  - Accepts 1 argument, required: target directory
9. Preprocess - Generate csv containing a list of all triggering tests for all versions of a project
  - Checkout to bugs_csv branch of defects4j at the time of writing
  - Run defects4j query -p [project] -q “trigger_tests” > [project]\_triggers.csv
10. Replace “::” with “.” for each method in the trigger csv - **doublecolontoperiod.sh**
  - Accepts 1 argument - target directory of triggers csvs
11. Find where triggers are in the ranking **totalfailures.sh/totalfaults.sh**
  - Accepts 3 arguments,required
      - Trigger csv file location
      - Target directory where sorted,tech col added ranking csvs are
      - Project id
12. Merge all techniques of a ranked technique csv into 1 csv - **mergetechs.sh**
  - 2-4 argument, required - targetdir of dir of each technique ranked file
  - Will take first folder as master
  - Slaves will look for version number of master
13. Make test case names all the same without breadcrumbs - **shortentestnames.sh**
  - Targetdir of where merged ranked failures or faults are


### Execution time
A text file for each version containing the execution time should have been created (6)

1. Put all of the raw execution text files in a subfolder in metrics/
2. Use **extracttime.sh** for techniques executed once
3. use **batchextracttime.sh** for techniques executed > 1, like Random.

### Coverage
1. Convert all_tests to reusable coverage method format - **covreorgmethlist.sh**
2. execute coverage for each test - **coverage.sh**
  - Text file generated containing condition and line coverage
3. Note these coverage scripts are not exactly complete(due to limited time and non-inclusion of final thesis) - Defects4j documentation should be read first, and scripts should be understood.
