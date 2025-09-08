from flask import Flask, render_template, request, make_response, g
import redis
import os
import socket
import random
import json

app = Flask(__name__)

def get_redis():
    if not hasattr(g, 'redis'):
        g.redis = redis.Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)
    return g.redis

@app.route("/", methods=['POST','GET'])
def hello():
    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == 'POST':
        redis_conn = get_redis()
        vote = request.form['vote']
        data = json.dumps({'voter_id': voter_id, 'vote': vote})
        redis_conn.rpush('votes', data)

    resp = make_response(render_template(
        'index.html',
        option_a='Cats',
        option_b='Dogs',
        hostname=socket.gethostname(),
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)