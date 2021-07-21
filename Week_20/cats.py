#! /usr/bin/env python3
'''
1.	Write a python program (not a Jupyter notebook, but a py file you run from the command line)
 that accepts the cats_txt.txt file as input and counts the frequency of all words and 
 punctuation in that text file, ordered by frequency. 
 Make sure to handle capital and lowercase versions of words and count them together.
 '''
import sys


def text_freq(filename):
    '''
    Takes in a string that is a filename.
    Outputs words and punctuation with frequency
    ''' 
    from nltk.tokenize import wordpunct_tokenize
    from collections import Counter 

    cats_file = open(filename, 'r') 
    # read file as string   
    cats = cats_file.read().replace("\n", " ")
    cats_file.close()
    # make string lowercase
    cats = cats.lower()
    # tokenize
    cats_tokens = wordpunct_tokenize(cats)
    # create frequency list
    cats_freq = Counter(cats_tokens)

    return cats_freq.most_common()

print(text_freq('cats_txt.txt'))