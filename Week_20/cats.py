#! /usr/bin/env python3
'''
1.	Write a python program (not a Jupyter notebook, but a py file you run from the command line)
 that accepts the cats_txt.txt file as input and counts the frequency of all words and 
 punctuation in that text file, ordered by frequency. 
 Make sure to handle capital and lowercase versions of words and count them together.
 '''
import sys
from nltk.tokenize import wordpunct_tokenize
from collections import Counter

cats_file = open('cats_txt.txt', 'r') 
cats = cats_file.read().replace("\n", " ")
cats_file.close()

cats = cats.lower()
cats_tokens = wordpunct_tokenize(cats)
cats_freq = Counter(cats_tokens)
print(cats_freq.most_common())