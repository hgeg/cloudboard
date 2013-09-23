import time,json
import requests, hashlib
import threading
from Pubnub import Pubnub

import pyperclip

USER = "Hgeg"
PASS = "sokoban"

pubnub = Pubnub(
        "pub-56806acb-9c46-4008-b8cb-899561b7a762",  ## PUBLISH_KEY
        "sub-26001c28-a260-11e1-9b23-0916190a0759",  ## SUBSCRIBE_KEY
        "sec-MGNhZWJmZmQtOTZlZS00ZjM3LWE4ZTYtY2Q3OTM0MTNhODRj",    ## SECRET_KEY
        False    ## SSL_ON?
)
    
def setGlobal(content):

    API_KEY = 'H4vlwkm8tvO8'
    API_SECRET ='UZepT6F8abA80DK1ilCz'
    timestamp = int(time.time())

    payload = {
      'data': content,
      'user': USER,
      'key': API_KEY,
      'timestamp': timestamp,
      'signature': hashlib.md5('%s&%s&%s'%(timestamp,hashlib.md5(PASS).hexdigest(),API_SECRET)).hexdigest()
      }

    r = requests.post('http://0.0.0.0:8787/set/',params=payload)

def setLocal(message):
  pyperclip.copy(message['text'])
  print "cboard:",pyperclip.paste()

def subscribe():
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
        sub_thread = threading.Thread(target=subscribe)
        sub_thread.daemon=True
        sub_thread.start()

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
    watcher = ClipboardWatcher(setGlobal,5.0)
    watcher.start()
    while True:
        try:
            print "Waiting for changed clipboard..."
            time.sleep(10)
        except KeyboardInterrupt:
            watcher.stop()
            break

if __name__ == "__main__":
    main()
