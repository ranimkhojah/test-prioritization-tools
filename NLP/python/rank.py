import numpy as np
import pandas as pd
import spacy
from tqdm import tqdm
import hdbscan
from spacy.lang.en.stop_words import STOP_WORDS
import csv
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
import os
import os.path
from matplotlib.collections import LineCollection
from sklearn import manifold
from sklearn.metrics import euclidean_distances
from nltk.stem import WordNetLemmatizer 
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.stem import PorterStemmer

print('loading model ...')
nlp = spacy.load('en_core_web_sm')
print('loading done!')

#Variables
dis_mat=[]
tcs=[]
folder = "ct"
lemmatizer = WordNetLemmatizer() 
porter = PorterStemmer()
#Functions
def remove_stop_words(text):
    return ' '.join([word for word in text.split(' ') if word.lower() not in STOP_WORDS])
def remove_intro(text):
    INTRO= ["This", "basic", "testcase", "is", "designed", "to", "verify", "that", "test", "check", "purpose", "steps", "expected", "outcome", "Conditions", "initial", "Steps/Description", "following", "links", "each", "mozilla"]
    return ' '.join([word for word in text.split(' ') if word.lower() not in INTRO])
def clean(text):
    return remove_intro(remove_stop_words(text))
def all_file_content(directory_name):
    file_list = os.listdir(directory_name)
    for file_name in file_list:
        with open(os.path.join(directory_name, file_name), "r") as src_file:
            yield src_file.read()
def stemSentence(sentence):
    token_words=word_tokenize(sentence)
    stem_sentence=[]
    for word in token_words:
        stem_sentence.append(porter.stem(word))
        stem_sentence.append(" ")
    return "".join(stem_sentence)
def flatten(seq):
  for el in seq:
    if isinstance(el, list):
      yield from flatten(el)
    else:
      yield el
def find_maximin_sequence(dm):
    N = len(dm)
    selected = []
    unselected = []

    dm = flatten(dis_mat)
    maxdis =max(dm)
    idx = dm.index(max(dm))


#read file names
for file_content in all_file_content(folder):
    file_list = os.listdir(folder)
    tcs.append(file_content)
# print(file_list)

#create distance matrix
for tc_a in tcs:
    for tc_b in tcs:
        sim = nlp(stemSentence(clean(tc_a))).similarity(nlp(stemSentence(clean(tc_b))))
        dis_mat[tcs.index(tc_a)].append(1-sim)

dm = flatten(dis_mat)
maxdis =max(dm)
idx = dis_mat.index(max(dis_mat))

print(dis_mat)