#! /usr/bin/env python3

import json
import psutil
import random
import shlex
import subprocess
import time
import urllib.parse
import urllib.request


N = 10
tf = "{:.3f}"


def process(code):
    data = urllib.parse.urlencode(dict(code=code, accepted_tos="true"))
    data = data.encode('ascii')
    with urllib.request.urlopen("http://localhost:8888/service", data) as f:
        return json.loads(f.read())

def compute_check():
    a, b = random.randint(-2**31, 2**31), random.randint(-2**31, 2**31)
    reply = process("print({} + {})".format(a, b))
    assert(int(reply['stdout'].strip()) == a + b)
    return reply


last_error = start = time.time()
subprocess.Popen(shlex.split("../sage/sage web_server.py"))

while True:
    try:
        print(compute_check())
        first_reply = time.time()
        break
    except Exception as e:
        last_error = time.time()
    time.sleep(0.1)
print("last error was at {}".format(last_error - start))
print("correct reply obtained at {}, {} later".format(
    first_reply - start, first_reply - last_error))

#print(process("print(1+*1)"))  # Syntax error
#print(process("while True: 1"))    # Timeout

if N:
    time.sleep(5)   # Let preforking etc to catch up
    batch_start = time.time()
    reply_times = []
    print("all times  ", end="")
    for i in range(N):
        iter_start = time.time()
        compute_check()
        reply_times.append(time.time() - iter_start)
        print(tf.format(reply_times[-1]), end=" ", flush=True)
    all_done = time.time()
    print()
    print("sorted times " + " ".join(tf.format(t) for t in sorted(reply_times)))
    print("{} more replies obtained at {}, {} per request".format(
        N, all_done - start, (all_done - batch_start)/N))
    print("fastest reply {}, slowest reply {}".format(
        min(reply_times), max(reply_times)))

#time.sleep(2)   # Let non-participating code work a bit as well
for p in psutil.process_iter(attrs=["pid", "cmdline"]):
    if p.info["cmdline"] == ["python", "web_server.py"]:
        p.terminate()
print("shutdown at {}".format(time.time() - start))
