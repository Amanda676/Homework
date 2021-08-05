from flask import Flask, render_template, request
from flask_pymongo import PyMongo
import datetime

app = Flask(__name__)

#setup mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/shows_db"
mongo = PyMongo(app)

#connect to collection
tv_shows = mongo.db.tv_shows

#READ
@app.route("/")
def index():
    #find all items in db and save to variable
    all_shows = list(tv_shows.find())
    print(all_shows)

    return render_template("index.html",data=all_shows)

#CREATE
@app.route("/add_record", methods=["POST", "GET"])    
def add_record():
    if request.method == "POST":
        # data in a dictionary
        data = request.form

        post_data = {'name': data['name'], 
            'seasons': data['num_seasons'],
            'duration': data['dur'],
            'year': data['yr'],
            'date_added': datetime.datetime.utcnow()
            }

        tv_shows.insert_one(post_data)

        return '<p>Data added </p>'

    else:    
        return render_template("add_record.html")

#DELETE
@app.route("/delete", methods=["POST", "GET"])
def delete():
    if request.method == "POST":
        # data in a dictionary
        data = request.form

        tv_shows.delete_one({'name': data['name']})

        return '<p>Data removed </p>'

    else:    
        return render_template("delete.html")

#UPDATE
@app.route("/update", methods=["POST", "GET"])
def update():
    if request.method == "POST":
        # data in a dictionary
        data = request.form

        update_show = {"name" : data['namefind']}

        post_data = { '$set': {'name': data['name'], 
            'seasons': data['num_seasons'],
            'duration': data['dur'],
            'year': data['yr'],
            }}

        tv_shows.update_one(update_show, post_data)

        return '<p>Data updated </p>'

    else:    
        return render_template("update.html")


if __name__ == "__main__":
    app.run(debug=True)