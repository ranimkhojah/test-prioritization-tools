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
folder = "bm"
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

#read file names
for file_content in all_file_content(folder):
    file_list = os.listdir(folder)
    tcs.append(file_content)
print(file_list)

#create distance matrix
for tc_a in tcs:
    dis_mat.append([])
    tcNo = str(tcs.index(tc_a)+1)
    dis_mat[tcs.index(tc_a)].append(file_list[tcs.index(tc_a)])
    for tc_b in tcs:
        sim = nlp(stemSentence(clean(tc_a))).similarity(nlp(stemSentence(clean(tc_b))))
        dis_mat[tcs.index(tc_a)].append(1-sim)
       
#add desciption column and row
desc = ['']
for i in range(len(tcs)):
    file_list = os.listdir(folder)
    desc.append(file_list[i])
dis_mat = np.vstack([desc, dis_mat])

# export distance matrix in .csv format
with open("matrix.csv","w+") as my_csv:
    csvWriter = csv.writer(my_csv,delimiter=',')
    csvWriter.writerows(dis_mat)




#Visualization

def get_word_vectors(words):
    # converts a list of words into their word vectors
    return [nlp(word).vector for word in words]

words = tcs
# intialise pca model and tell it to project data down onto 2 dimensions
pca = PCA(n_components=2)
pca.fit(get_word_vectors(words))
word_vecs_2d = pca.transform(get_word_vectors(words))


# create a nice big plot 
plt.figure(figsize=(15,10))

# plot the scatter plot of where the words will be
plt.scatter(word_vecs_2d[:,0], word_vecs_2d[:,1])

# for each word and coordinate pair: draw the text on the plot
for word, coord in zip(file_list, word_vecs_2d):
    x, y = coord
    plt.text(x, y, word, size= 15)

# show the plot
plt.show()
