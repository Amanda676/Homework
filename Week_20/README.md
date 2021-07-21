# cats.py ReadMe

### What is cats.py

cats.py is a python program that inputs the cats_txt.txt and prints a list of tuples containing the word and count of the input.  An example tuple: ('show', 7)

The output descends from most frequent to least frequent.

### How to run the cats.py file

Make sure you have python3 installed and nltk library.

Before running, download the cats.py and cats_txt.txt to the same directory of your choice.  

1. Open a terminal window or shell prompt.

2. Change to the directory where the cats.py and cats_txt.txt are held.  The command cd can help.

3. At the command prompt, type:
        python3 cats.py

![cats.py command line png](https://github.com/Amanda676/Homework/blob/main/Week_20/cats_command.png)

4. Press return.

5. cats.py returns the word frequency from cats_txt.txt descending from most frequent.

![cats.py output png](https://github.com/Amanda676/Homework/blob/main/Week_20/cats_output.png)

### Alternative run

If you have execute permission on the file, it is possible to run it from the directory it was placed in using:
        ./cats.py

### Why?

Being able to create a 'bag of words' frequency list would be helpful Natural Language Processing (NLP) because it can useful to know the most frequent to quickly know what a text is about.