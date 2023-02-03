# Text-based Diversity Prioritization Techniques
This is the reproduction package for the paper _"Evaluating the Trade-offs of Text-based Diversity in Test Prioritisation"_ by Khojah et al.
The package includes scripts to run Jaccard, NCD, Levenshtein, Random and Semantic Similarity (using NLP) as well as the Doc2Vec model that was used to perform Semantic Similarity. Scripts to measure the coverage, failures and execution time of each technique on 3 levels of testing are also included

## System and integration level
### Lexical distance measures (Jaccard, NCD and Levenshtein)
#### Pre-requisits 
1) Anaconda shell is preferable to run the programs
2) The program runs on Julia 1.5 or latest
3) The following packages should be installed
   
    | Package        | Version       | 
    | ------------- |:-------------:| 
    | docker | 20.10 | 

#### How to run
1) cd to `src/distance_measures/`
2) Locate your test files in `data/` directory
3) Run `sh lexical_distance_measures.sh`


### Semantic Similarity (SS)
#### Pre-requists
1) Anaconda shell is preferable to run the programs
2) The program runs on Python 3.7 or latest
3) The following packages should be installed

    | Package        | Version       | 
    | ------------- |:-------------:| 
    |gensim | 3.8.1 | 
    | jupyter | 1.0.0 |
    |sklearn  |  0.0  | 
    |numpy |1.18.1  |
    |pandas | 1.0.3 |
    |nltk|3.4.5|
    | regex |  2017.4.5 |
    | stop-words | 2018.7.23 |
    | tensorflow | 2.1.0 |
    | sent_tokenize| |
    | stem | 1.8.0 |


#### Steps to perform SS using a pre-trained D2V model on Wikipedia data
1) cd to `test-prioritization-tools/src/SS/python`
2) Locate your set in a folder called `dir` in the same location where `d2v.py` is located
3) Each test description file should correspond to one test case and in .txt format
4) Run `d2v.py` via `python d2v.py`

#### Outcome
A csv file that includes a distance matrix calculated by cosine distance function.

#### Other Options
1) interpret the distance matrix into a ranking by running the `Julia mdistmain.jl distance_matrix.csv` in Julia folder
2) Create a random ranking by cd to `test-prioritization-tools/src/Random` then placing `dir` as a test suite folder and finally run `python random_test_specs.py`.
3) Calculate the coverage of the generated ranking.

## Coverage
There are 2 coverage scripts that can be used for 2 different formats of tests:
1) [ Company A ] Extracting system-level tests from seperate text files in a directory.
2) [ Company B ] Extracting integration-level tests from a test suite and the corresponding system-level tests from the docstrings of each test in the test suite.
   
#### How to run
1) cd to `src/coverage/`
2) run `python check_coverage_companyA` or `python check_coverage_companyB`


  _\* Note that the coverage scripts expect a ranking of the tests and a mapping of the tests to the requirement / feature covered._  

### Random
#### How to run
1) cd to `src/Random/`
2) Run python `random_test_spec.py <path_to_directory_with_test_files>`
3) The script will run Random 10 times (could be adjusted in the code)
4) The output is a folder `randomfiles/` with 10 files of 10 random rankings of the test files

## Unit level
### Use D4j scripts to process Junit tests in Java

#### Prerequisites
Defects4j needs to be set up first.
The scripts are shell scripts, and thus require bash.

### Defects4j Pipeline

1. Checkout all versions of a project with `checkoutallfixedversions.sh`
  - Accepts 3 parameters all 3 required
    - Project identifier to checkout
    - Starting bug version
    - Ending bug version
  - Must make parent directory first, needs to be labelled the same as project identifier
  - Versions will be inside that folder

2. Test each version with `testprojects.sh`
  - Takes 1 parameter, required
    - Target directory of where all the checked out versions are
  - Need to do this to get all_tests. 
1. Retrieve a list of method names with  `renamealltests.sh`
  - Takes 1 parameter, required
    - Target directory of where the parent directory is
      - Example: Lang > lang1, lang2, lang3
    - Lang is the parent directory
  - Folder called “methlist” must be created beforehand in the same place where renamealltests is
1. Restructure/reorganize the list with `reorgmethlist.sh`
  - Accepts 1 parameter, required
    - Target directory of where the extracted method name lists are
  - `reorgmethlist.sh` uses `methodlist.awk`
  - To run `methodlist.awk` itself, use awk file with `awk -f methodlist.awk [location of methodlist file]`.
  - `reorganizedMeths/` folder should already be created
1. Separate methods by running `felixMethSep`
  - Before running the tool:
    - Put all the restructured methodlists into `target/surefire-reports`
    - Copy all the respective checked out versions of corresponding projects to `target/projects_to_separate.` The entire projects.
  - Run the maven project. Its a maven project.
  - The resulting code will be in `target/pit-reports/code`.
1. Ranking.
  - Depending on technique, 3 choices:
    - `Jaccarddivseq.sh`, `levendivseq.sh`, `ncddivseq.sh`, `randomdivseq.sh`
    - Accepts 1 argument, required
      - Target directory where all directories of the extracted code is, 1 level deep.
  - Generates both the rankings and execution time, which is outputted into a different file of just the stdout
  - Randomdivseq generates the rankings in `rankedtests/`
1. Preprocess for Failures - sort rankings - `rankedtests/sortrankings.sh`
  - Ranking csv needs to be sorted in ascending order for easier processing
  - Accepts 1 argument, required - target directory where all rankings are stored
1. Preprocess - Add “technique” column, shift other columns right - `rankedtests/shiftcolright.sh*`
  - Accepts 1 argument, required: target directory
1. Preprocess - Generate csv containing a list of all triggering tests for all versions of a project
  - Checkout to bugs_csv branch of defects4j at the time of writing
  - Run `defects4j query -p [project] -q “trigger_tests” > [project]\_triggers.csv`
1.  Replace “::” with “.” for each method in the trigger csv - `doublecolontoperiod.sh`
  - Accepts 1 argument - target directory of triggers csvs
1.  Find where triggers are in the ranking `totalfailures.sh/totalfaults.sh`
  - Accepts 3 arguments,required
      - Trigger csv file location
      - Target directory where sorted,tech col added ranking csvs are
      - Project id
1.  Merge all techniques of a ranked technique csv into 1 csv - `mergetechs.sh`
  - 2-4 argument, required - targetdir of dir of each technique ranked file
  - Will take first folder as master
  - Slaves will look for version number of master
1.  Make test case names all the same without breadcrumbs - `shortentestnames.sh*`
  - Targetdir of where merged ranked failures or faults are


### Execution time
A text file for each version containing the execution time should have been created

1. Put all of the raw execution text files in a subfolder in `metrics/`
2. Use `extracttime.sh` for techniques executed once
3. use `batchextracttime.sh` for techniques executed > 1, like Random.

### Coverage
1. Convert all_tests to reusable coverage method format - `covreorgmethlist.sh`
2. execute coverage for each test - `coverage.sh`
  - Text file generated containing condition and line coverage