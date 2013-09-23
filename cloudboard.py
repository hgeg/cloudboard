#!/usr/bin/env python
import web, redis, shelve, hashlib, json
from Pubnub import Pubnub
import time

pubnub = Pubnub(
        "pub-56806acb-9c46-4008-b8cb-899561b7a762",  ## PUBLISH_KEY
        "sub-26001c28-a260-11e1-9b23-0916190a0759",  ## SUBSCRIBE_KEY
        "sec-MGNhZWJmZmQtOTZlZS00ZjM3LWE4ZTYtY2Q3OTM0MTNhODRj",    ## SECRET_KEY
        False    ## SSL_ON?
)

urls = (
    '/cloudboard/', 'Main',
    '/cloudboard', 'Main',
    '/cloudboard/auth/', 'Auth',
    '/cloudboard/set/', 'Setter',
    '/cloudboard/get/', 'Getter',
)

app = web.application(urls, globals())

api_tokens = {
    'H4vlwkm8tvO8':'UZepT6F8abA80DK1ilCz',
    'K3lgHzd1hp1V':'Rx37kn24Ctz4b0p6bBI7'
}

class Main:
  def GET(self):
    rd = redis.StrictRedis(host='localhost', port=6379, db=0)
    return "Welcome to Cloudboard. TEST:%s"%rd.get('Hgeg')

class Auth:
  def GET(self): pass
  def POST(self): pass

class Setter:
  def GET(self):
    return '{"error":true,"data":{"msg":"Invalid request type(GET).", "type":"RequestError", "errcode":21}}'
  def POST(self):
    web.header('Content-Type', 'application/json')
    #initialize data containers
    rd = redis.StrictRedis(host='localhost', port=6379, db=0)
    db = shelve.open('auth')
    post = web.input()
    
    #check timeframe:
    if int(time.time()) > int(post.timestamp) + 120:
      return '{"error":true,"data":{"msg":"Request is too old.", "type":"AuthError", "errcode":11}}'

    #reconstruct signature
    secret = api_tokens[post.key]
    timestamp = post.timestamp
    user = post.user
    signature = hashlib.md5('%s&%s&%s'%(timestamp,db[user],secret)).hexdigest()
    if signature != post.signature:
        return '{"error":true,"data":{"msg":"Signature does not match." "type":"AuthError", "errcode":12}}'
    rd.set(user,post.data)
    info = pubnub.publish({
      'channel' : user,
      'message' : {
        'text' : post.data
      }
    })
    print info
    return '{"error":false,"data:{"clipboard":"%s"}}'%rd.get(user)
      

class Getter:
  def GET(self):
    return '{"error":true,"data":{"msg":"Invalid request type(GET).", "type":"RequestError", "errcode":21}}'
  def POST(self):
    web.header('Content-Type', 'application/json')
    #initialize data containers
    rd = redis.StrictRedis(host='localhost', port=6379, db=0)
    db = shelve.open('auth')
    post = web.input()
    
    #check timeframe:
    if int(time.time()) > int(post.timestamp) + 120:
      return '{"error":true,"data":{"msg":"Request is too old.", "type":"AuthError", "errcode":11}}'

    #reconstruct signature
    secret = api_tokens[post.key]
    timestamp = post.timestamp
    user = post.user
    signature = hashlib.md5('%s&%s&%s'%(timestamp,db[user],secret)).hexdigest()
    if signature != post.signature:
        return '{"error":true,"data":{"msg":"Signature does not match." "type":"AuthError", "errcode":12}}'
    return '{"error":false,"data:{"clipboard":"%s"}}'%rd.get(user)

if __name__ == "__main__":
    web.wsgi.runwsgi = lambda func, addr=None: web.wsgi.runfcgi(func, addr)
    app.run()
