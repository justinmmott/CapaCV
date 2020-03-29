import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from inference.detect_people import count_people
from time import sleep

# Use a service account
cred = credentials.Certificate('serviceacct.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection(u'users')
docs = users_ref.stream()
for doc in docs: # Actually write data to database here
    print(u'{} => {}'.format(doc.id, doc.to_dict()))

while True:
    picture_path = 'inference/test_image.jpg'
    num_people = count_people(picture_path)
    print(num_people)
    sleep(3)
