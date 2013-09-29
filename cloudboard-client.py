#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import time,json
import requests,hashlib
import threading,uuid
from Pubnub import Pubnub

import pyperclip

USER = "Hgeg"
PASS = "sokoban"
UNIQUEID = "cboard-PC-%s"%uuid.getnode()

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
    with open('dump.html','w') as f: f.write(r.text.encode('utf-8'))
  except: pass

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
    pyperclip.copy(unicode(r.text).encode('utf-8'))
  except: pass

def subscribe():
  while True:
    pubnub.subscribe({
      'channel'  : USER,
      'callback' : setLocal
    })

class ClipboardWatcher(threading.Thread):
    def __init__(self, callback, pause=5.0):
        super(ClipboardWatcher, self).__init__()
        self._callback = callback
        self._pause = pause
        self._stopping = False
        self._sub = threading.Thread(target=subscribe)
        self._sub.daemon=True
        self._sub.start()

    def run(self):       
        recent_value = ""
        while not self._stopping:
            tmp_value = pyperclip.paste()
            if tmp_value != recent_value:
                recent_value = tmp_value
                self._callback(recent_value)
            time.sleep(self._pause)

    def stop(self):
        self._stopping = True

def main():
    setLocal({'uniqueID':'None'})
    watcher = ClipboardWatcher(setGlobal,0.5)
    watcher.start()
    while True:
        try:
            time.sleep(1)
        except KeyboardInterrupt:
            watcher.stop()
            break

if __name__ == "__main__":
    main()
