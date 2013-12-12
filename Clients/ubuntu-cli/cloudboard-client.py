#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import time,json,argparse
import requests,hashlib
import uuid,sys
from Pubnub import Pubnub

USER = "Hgeg"
PASS = "sokoban"
UNIQUEID = "cboard-cli-%s"%uuid.getnode()

clipDict = {}
clipText = ''
clipLen  = 0

pubnub = Pubnub(
        "pub-56806acb-9c46-4008-b8cb-899561b7a762",  ## PUBLISH_KEY
        "sub-26001c28-a260-11e1-9b23-0916190a0759",  ## SUBSCRIBE_KEY
        "sec-MGNhZWJmZmQtOTZlZS00ZjM3LWE4ZTYtY2Q3OTM0MTNhODRj",    ## SECRET_KEY
        False    ## SSL_ON?
)
    
def setGlobal(content):
  try: 
    API_KEY = 'H4vlwkm8tvO8'
    API_SECRET ='UZepT6F8abA80DK1ilCz'
    timestamp = int(time.time())

    payload = {
      'data': content.decode('utf-8'),
      'user': USER,
      'key': API_KEY,
      'timestamp': timestamp,
      'signature': hashlib.md5('%s&%s&%s'%(timestamp,hashlib.md5(PASS).hexdigest(),API_SECRET)).hexdigest(),
      'uniqueID':UNIQUEID
      }
    headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
    r = requests.post('http://hgeg.io/cloudboard/set/',data=json.dumps(payload),headers=headers)
    print r.text.encode('utf-8')
    #with open('dump.html','w') as f: f.write(r.text.encode('utf-8'))
    return "OK"
  except: return "Fatal Error!"

def setLocal(message):
  try:
    if message['uniqueID'] == UNIQUEID: return 
    API_KEY = 'H4vlwkm8tvO8'
    API_SECRET ='UZepT6F8abA80DK1ilCz'
    timestamp = int(time.time())

    payload = {
      'user': USER,
      'key': API_KEY,
      'timestamp': timestamp,
      'signature': hashlib.md5('%s&%s&%s'%(timestamp,hashlib.md5(PASS).hexdigest(),API_SECRET)).hexdigest(),
      'uniqueID':UNIQUEID
      }

    r = requests.post('http://hgeg.io/cloudboard/get/',params=payload)
    return unicode(r.text).encode('utf-8')
  except: return "cboard_nil"

def subscribe():
  while True:
    pubnub.subscribe({
      'channel'  : USER,
      'callback' : setLocal
    })

def paste():
    return setLocal({'uniqueID':'None'})

def copy(mesg):
    return setGlobal(mesg)

def main():
    parser = argparse.ArgumentParser(description="copy and paste data on command line interface.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-p","--paste",action="store_true",help="paste from your cloudboard")
    group.add_argument("-c","--copy", metavar="DATA",help="copy to your cloudboard")
    args = parser.parse_args()

    if(args.copy): sys.stdout.write(copy(args.copy))
    else: sys.stdout.write(paste())

if __name__=="__main__": main()
