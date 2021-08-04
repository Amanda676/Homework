#!/usr/bin/env python

from bs4 import BeautifulSoup as bs
import requests
from scrapy import Selector
import time
from flask import Flask, json, render_template, request, redirect
import os

#create instance of Flask app
app = Flask(__name__)

#decorator 
@app.route("/")
def home_page():
    welcome_msg = '<h1>Gather and Display Yelp Data</h1> \
    <p>/all for current yelp data</p> \
    <p>/scrape to gather yelp data and replace old data, redirects to /all</p>'
    return welcome_msg

@app.route("/all")
def all():
    json_url = os.path.join(app.static_folder,"","yelp_data.json")
    data_json = json.load(open(json_url))
    #render_template is always looking in templates folder
    return render_template('index.html',data=data_json)

@app.route("/scrape")
def scrape():
    # adding functions to scrape
    def scrape_urls():
        # function to get 50 restaurant urls
        # returns list of the 50 urls
        top_50_url = []
        for i in range(0, 50, 10):
            time.sleep(2)
            # url, with 10 restaurants at a time
            url = f'https://www.yelp.com/search?find_desc=Restaurants&find_loc=63040&start={i}'
            try:
                response = requests.get(url)
                soup = bs(response.text, 'html.parser')
                # get the top names
                ten_names = soup.find_all('span',class_="css-1pxmz4g")

                # first two and last parts of the list are ads, ignore
                for j in range(0, len(ten_names)):
                    #get url to visit
                    top_50_url.append(ten_names[j].a.get('href'))
            except AttributeError as e:
                print(e)
        
        return top_50_url
    
    def get_rest_info(url_list):
        # takes list of urls to scrape on yelp
        # returns list of dictionaries with info
        
        top_50_url = url_list
        list50_restaurants = []
        #iterate over top_50_urls
        for i in range(0, len(top_50_url)):
            #add sleep function 
            time.sleep(3)
            
            #print progress every 5 visits
            if i%5 == 0:
                print("Visiting urls: ", str(i))
            
            # make urls
            url = f'https://www.yelp.com{top_50_url[i]}'

            try:
                response = requests.get(url)
                soup = bs(response.text, 'html.parser')
                sel = Selector(text = response.text)

                # order from yelp
                rank = i+1

                # get restaurant name
                name = soup.find('h1', class_="css-11q1g5y").text

                # get address
                try:
                    address = soup.find('p', class_="css-chtywg").text
                except:
                    address = ''

                #get number of stars with xpath, extract from list
                try:
                    stars = sel.xpath \
                    ('//*[@id="wrap"]/div[2]/yelp-react-root/div[1]/div[3]/div[1]/div[1]/div/div/div[2]/div[1]/span/div/@aria-label').extract()
                    stars = stars[0]
                except:
                    stars = ''

                # build category list
                category = []

                # number of reviews, text
                # exception for only 1 in the list
                try:
                    cat_list = soup.find_all('span', class_="css-bq71j2")
                    # if there is only one thing in the list, it's not number of reviews,
                    # it's the category
                    if len(cat_list) == 1:
                        num_reviews = 0
                        category.append(cat_list[0].a.text)
                    else:
                        num_reviews = cat_list[0].text
                except:
                    num_reviews = 0

                # find the categories listed for the restaurant
                try:
                    for i in range(1, len(cat_list)):
                        category.append(cat_list[i].a.text)
                except:
                    pass

                rest_dict = {"Rank": rank,
                            "Restaurant_Name": name,
                            "Address": address,
                            "Stars": stars,
                            "Number_Reviews": num_reviews,
                            "Category": category}
                list50_restaurants.append(rest_dict)

            except AttributeError as e:
                print(e)

        return list50_restaurants

    urls_to_scrape = scrape_urls()
    yelp_data = get_rest_info(urls_to_scrape)

    filenm = "./static/yelp_data.json"

    with open(filenm,'r+') as file:
        file.seek(0)
        json.dump(yelp_data, file, indent = 4)

    return redirect("/all")

'''
@app.route("/test")
def test():
    return redirect("/")
 '''   

if __name__ == "__main__":
    app.run(debug=True)

# adding functions to scrape
def scrape_urls():
    # function to get 50 restaurant urls
    # returns list of the 50 urls
    top_50_url = []
    for i in range(0, 50, 10):
        time.sleep(2)
        # url, with 10 restaurants at a time
        url = f'https://www.yelp.com/search?find_desc=Restaurants&find_loc=63040&start={i}'
        try:
            response = requests.get(url)
            soup = bs(response.text, 'html.parser')
            # get the top names
            ten_names = soup.find_all('span',class_="css-1pxmz4g")

            # first two and last parts of the list are ads, ignore
            for j in range(0, len(ten_names)):
                #get url to visit
                top_50_url.append(ten_names[j].a.get('href'))
        except AttributeError as e:
            print(e)
    
    return top_50_url

def get_rest_info(url_list):
    # takes list of urls to scrape on yelp
    # returns list of dictionaries with info
    
    top_50_url = url_list
    list50_restaurants = []
    #iterate over top_50_urls
    for i in range(0, len(top_50_url)):
        #add sleep function 
        time.sleep(3)
        
        #print progress every 5 visits
        if i%5 == 0:
            print("Visiting urls: ", str(i))
        
        # make urls
        url = f'https://www.yelp.com{top_50_url[i]}'

        try:
            response = requests.get(url)
            soup = bs(response.text, 'html.parser')
            sel = Selector(text = response.text)

            # order from yelp
            rank = i+1

            # get restaurant name
            name = soup.find('h1', class_="css-11q1g5y").text

            # get address
            try:
                address = soup.find('p', class_="css-chtywg").text
            except:
                address = ''

            #get number of stars with xpath, extract from list
            try:
                stars = sel.xpath \
                ('//*[@id="wrap"]/div[2]/yelp-react-root/div[1]/div[3]/div[1]/div[1]/div/div/div[2]/div[1]/span/div/@aria-label').extract()
                stars = stars[0]
            except:
                stars = ''

            # build category list
            category = []

            # number of reviews, text
            # exception for only 1 in the list
            try:
                cat_list = soup.find_all('span', class_="css-bq71j2")
                # if there is only one thing in the list, it's not number of reviews,
                # it's the category
                if len(cat_list) == 1:
                    num_reviews = 0
                    category.append(cat_list[0].a.text)
                else:
                    num_reviews = cat_list[0].text
            except:
                num_reviews = 0

            # find the categories listed for the restaurant
            try:
                for i in range(1, len(cat_list)):
                    category.append(cat_list[i].a.text)
            except:
                pass

            rest_dict = {"Rank": rank,
                        "Restaurant_Name": name,
                        "Address": address,
                        "Stars": stars,
                         "Number_Reviews": num_reviews,
                        "Category": category}
            list50_restaurants.append(rest_dict)

        except AttributeError as e:
            print(e)

    return list50_restaurants
    