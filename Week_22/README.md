### yelp.py

# Pictures of website are in the jupyter notebook

Approach:

First, I created a function to scrape the urls of the restaurant pages I needed to visit.  Second, I created a function to visit each page and gather the information.   The code and website could be modified to take in a variable like a zip code (for location) and number (for number of restaurant data to collect).

A few issues:

1.  Sometime yelp just didn't respond and got no information for that "visit."   I did have one run of all the code were the data all came through.   I think this had to do with robot blocking.   I tried adding wait time to see if this would improve things, but I'm not sure it worked.

2.  I thought python scope for functions worked like variables.   So if I call a function(x) in a function(y), if the function is not defined in y, it would look one level out to find function x.  This did not work for me in the yelp.py file.   I had to create and call the functions in the /scrape function, instead of outside the scrape function.

3.  I could not figure out how to delete and recreate my data file as I would have liked.  I understand opening it and adding all my data, but if the data changed, I cannot just recreate the .json file from scratch.   I tried using the os to remove the file (which worked), but I could not use open to create the file.   I have no idea why.  Googling a few different search terms all talked about appending json files.

**What is web scraping? Why is it helpful? Why is it sometimes in a legal grey area or just plain illegal?!**

Webscraping is automating visiting a website and gathering and saving data(content). It can be helpful to track changes, gather large amounts of data for processing, automate testing, keep tabs on competitors, and more.

Sometimes, certain types of (or all) webscraping is against the terms of service for a website. Visit the site's robots.txt file to find out more. Webscraping legality may depend on the use of the data, copyright, and the country or jurisdiction. Websites may also take measures to prevent scraping bots.