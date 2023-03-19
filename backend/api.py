#make simple fastapi backend for the frontend
from fastapi import FastAPI
import os
import json
from fastapi import Request
import datetime

if os.path.exists("database.json"):
    print("database exists")
    with open("database.json", "r") as f:
        database = json.load(f)
else:
    database = {}

DEFAULT_ACTIVE_HOURS = 3
app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

#login with email and password
@app.get("/login")
async def login(user: str, password: str):
    user = user.lower()
    print(user, password)
    if len(user) == 0 or len(password) == 0:
        return {"message": "please enter user and password"}
    if user in database:
        if database[user]["password"] == password:
            return {"message": "success"}
        else:
            return {"message": "wrong password or username"}
    else:
        return {"message": "wrong password or username"}

@app.get("/register")
async def register(user: str, password: str):
    user = user.lower()
    print(user, password)
    if len(user) == 0 or len(password) == 0:
        return {"message": "please enter user and password"}
    if user in database:
        return {"message": "email already exists"}
    else:
        database[user] = {"password": password,
                          "friends": [], 
                          "active": False,
                          "last_active": datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")}
        with open("database.json", "w") as f:
            json.dump(database, f)
        return {"message": "success"}

@app.get("/getfriends")
async def getfriends(user: str):
    user = user.lower()
    if len(user) == 0:
        return {"message": "please enter user"}
    if user in database:
        friends = []
        for friend in database[user]["friends"]:
            #check if friend is active and if not check if they have been active in the last 3 hours
            active = database[friend]["active"]
            if active:
                if datetime.datetime.now() - datetime.datetime.strptime(database[friend]["last_active"], "%d/%m/%Y %H:%M:%S") > datetime.timedelta(hours=DEFAULT_ACTIVE_HOURS):
                    active = False
            friends.append({"name": friend, "active": active})
        print(friends)
        return {"message": "success", "friends": friends}
    else:
        print("user does not exist")
        return {"message": "user does not exist"}
    
@app.get("/addfriend")
async def addfriend(currentUser: str, friend: str):
    currentUser = currentUser.lower()
    print(currentUser, friend)
    friend = friend.lower()
    if len(currentUser) == 0 or len(friend) == 0:
        return {"message": "please enter user and friend"}
    if currentUser in database:
        if friend in database:
            if friend not in database[currentUser]["friends"]:
                database[currentUser]["friends"].append(friend)
                with open("database.json", "w") as f:
                    json.dump(database, f)
                return {"message": "success"}
            else:
                return {"message": "friend already exists"}
        else:
            return {"message": "friend does not exist"}
    else:
        return {"message": "user does not exist"}
    
@app.post("/setactivity")
async def set_activity(request: Request):
    data = await request.json()
    user = data.get('user')
    user = user.lower()
    active = data.get('active')
    if user is None:
        return {"message": "please enter user"}
    if user in database:
        database[user]["active"] = active
        database[user]["last_active"] = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        with open("database.json", "w") as f:
            json.dump(database, f)
        return {"message": "success"}
    else:
        return {"message": "user does not exist"}

    
