import requests, hashlib
import time

USER = "Hgeg"
PASS = "sokoban"

API_KEY = 'H4vlwkm8tvO8'
API_SECRET ='UZepT6F8abA80DK1ilCz'
timestamp = int(time.time())

payload = {
  'data':'pastedstr:%d'%timestamp,
  'user':USER,
  'key':API_KEY,
  'timestamp':timestamp,
  'signature': hashlib.md5('%s&%s&%s'%(timestamp,hashlib.md5(PASS).hexdigest(),API_SECRET)).hexdigest()
  }

r = requests.post('http://0.0.0.0:8787/set/',params=payload)

print ""
print "setting clipboard:"
print r.text
print ""
payload = {
  'user':USER,
  'key':API_KEY,
  'timestamp':timestamp,
  'signature': hashlib.md5('%s&%s&%s'%(timestamp,hashlib.md5(PASS).hexdigest(),API_SECRET)).hexdigest()
  }

r = requests.post('http://0.0.0.0:8787/get/',params=payload)

print "getting existing clipboard:"
print r.text
print ""
