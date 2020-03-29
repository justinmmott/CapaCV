import json
from geopy.geocoders import Nominatim
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import googlemaps
import random

# Use a service account
cred = credentials.Certificate('firebaseacct.json')
firebase_admin.initialize_app(cred)

# Set up database
db = firestore.client()

# Set up googlemaps
gm = None
with open('gmapsacct.json', 'r') as api_file:
    gm = googlemaps.Client(json.load(api_file)['key'])
assert gm

# Maybe consider bakery and bar later?
types = {
    "Restaurant" : ["restaurant"],
    "Cafe" : ["cafe"],
    "Study" : ["library"],
    "Grocery" : ["grocery_or_supermarket"]
}

def generate_database_entry(info):
    if 'location' not in info:
        geolocator = Nominatim(user_agent="CapaCV")
        location = geolocator.geocode(info['address'])
        geopoint=firestore.GeoPoint(location.latitude, location.longitude)
        info['location'] = geopoint

    UID = info['uid']
    db.collection(u'places').document(UID).set(info)

def get_dump(radius, placetype):
    return f"data/dump{radius}{placetype}.json"

def generate_random_data(latitude, longitude, radius, placetype):
    gtype = types[placetype][0]
    res = gm.places_nearby(location = (latitude, longitude),
                           radius = radius,
                           type = gtype)
    with open(get_dump(radius, placetype), 'w') as out_file:
        json.dump(res, out_file)

def populate_dataset(data, placetype):
    for elem in data['results']:
        info = dict()
        hours_query = gm.place(elem['place_id'], fields = ['opening_hours'])
        if 'opening_hours' not in hours_query['result']:
            continue
        hours_data = hours_query['result']['opening_hours']['periods']
        info['hours'] = dict()
        info['hours']['open'] = int(hours_data[2]['open']['time'])
        info['hours']['close'] = int(hours_data[2]['close']['time'])
        info['name'] = elem['name']
        info['address'] = elem['vicinity']
        info['maxCapacity'] = random.randint(10, 30)
        info['currCapacity'] = random.randint(0, info['maxCapacity'])
        if 'rating' in elem:
            info['rating'] = elem['rating']
        else:
            info['rating'] = 0
        info['uid'] = elem['place_id']
        info['type'] = placetype
        if 'photos' in elem and elem['photos']:
            info['picture'] = elem['photos'][0]['photo_reference']
        else:
            info['picture'] = '0000'
        latitude = elem['geometry']['location']['lat']
        longitude = elem['geometry']['location']['lng']
        info['location'] = firestore.GeoPoint(latitude, longitude)
        generate_database_entry(info)

def view_dump(radius, placetype):
    data = json.load(open(get_dump(radius, placetype), "r"))
    for elem in data["results"]:
        for key, value in elem.items():
            print(key, value)
        print()

        
UCLA = (34.0689, -118.4452)
if __name__ == '__main__':
    """
    with open('data/room_info.json', 'r') as info_file:
        data = json.load(info_file)
        generate_database_entry(data)
    """
    radii = [200, 1000]
    for radius in radii:
        for placetype in types:
            print("Doing: ", radius, placetype)
            gtype = types[placetype][0]
            generate_random_data(UCLA[0], UCLA[1], radius, placetype)
            view_dump(radius, placetype)
            populate_dataset(json.load(open(get_dump(radius, placetype), 'r')), placetype)
