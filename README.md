# Lemon-Ginger-Thesis
### How to perform NLP on a set of test specifications
#### Pre-requists
1) Anaconda shell is preferable 
2) The program runs on Python 3.7
3) The following packages should be installed

| Package        | Version       | 
| ------------- |:-------------:| 
|en-core-web-md | 2.0.0         | 
|tqdm           | 4.43.0        | 
|numpy |1.18.1  |
|pandas | 1.0.2 |
| stop-words | |
| csv | |
| plt | |
|os| |
| LineCollection | |
| WordNetLemmatizer | |
| sent_tokenize| |
| word_tokenize | |
| stem | 1.8.0 |


#### Steps
1) cd to `Lemon-Ginger-Thesis/SS/python`
2) Locate your set in a folder called `dir` in the same location where `d2v.py` is located
3) Each test description file should correspond to one test case and in .txt format
4) Run `d2v.py` via `python d2v.py`

#### Outcome
A csv file that includes a distance matrix calculated by cosine distance function.

#### Other Options
1) interpret the distance matrix into a ranking by running the `Julia mdistmain.jl distance_matrix.csv` in Julia folder
2) Create a random ranking by cd to `Lemon-Ginger-Thesis/Random` then placing `dir` as a test suite folder and finally run `python random_test_specs.py`.
