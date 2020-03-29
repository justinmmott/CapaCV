import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from inference.detect_people import count_people_from_path
from capture.record import take_picture
from time import sleep
import cv2
import json
import os

# Use a service account
cred = credentials.Certificate('firebaseacct.json')
firebase_admin.initialize_app(cred)

# Set up database
db = firestore.client()

# Set up camera
def get_video_stream():
    return cv2.VideoCapture(0)
picture_path = 'data/room_picture.jpg'
snapshot_period = 3 # in seconds

# Set up room information for database
database_info_path = 'data/room_info.json'
UID = -1
with open(database_info_path, 'r') as info_file:
    room_data = json.load(info_file)
    UID = room_data['uid']
room_ref = db.collection(u'places').document(UID)
print("Room id: ", UID)
print("Data: ",room_ref.get().to_dict())

while True:
    stream = get_video_stream()
    take_picture(stream, picture_path)
    num_occupants = count_people_from_path(picture_path)
    os.remove(picture_path)
    room_ref.update({u'currCapacity' : num_occupants})
    print(num_occupants)
    sleep(snapshot_period)
