# Lemon-Ginger-Thesis
### How to perform Semantic Similarity (SS) on a set of test specifications using an NLP approach.
#### Pre-requists
1) Anaconda shell is preferable to run the programs
2) The program runs on Python 3.7.7 or latest
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
1) cd to `Lemon-Ginger-Thesis/SS/python`
2) Locate your set in a folder called `dir` in the same location where `d2v.py` is located
3) Each test description file should correspond to one test case and in .txt format
4) Run `d2v.py` via `python d2v.py`

#### Outcome
A csv file that includes a distance matrix calculated by cosine distance function.

#### Other Options
1) interpret the distance matrix into a ranking by running the `Julia mdistmain.jl distance_matrix.csv` in Julia folder
2) Create a random ranking by cd to `Lemon-Ginger-Thesis/Random` then placing `dir` as a test suite folder and finally run `python random_test_specs.py`.
3) Calculate the coverage of the generated ranking.
