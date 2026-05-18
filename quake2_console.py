from kubernetes import client, config
from kubernetes.stream import stream
from threading import Thread
import sys

quake2_pod = None

config.load_kube_config()
core_v1 = client.CoreV1Api()

pods = core_v1.list_namespaced_pod('default')
for pod in pods.items:
    if pod.metadata.name.startswith("basm-quake2"):
        quake2_pod = pod.metadata.name

if quake2_pod:
    # open stream
    resp = stream(core_v1.connect_get_namespaced_pod_attach,
                            quake2_pod,
                            "default",
                            stderr=True,
                            stdin=True,
                            stdout=True,
                            tty=True, _preload_content=False)

    # redirect input
    def read():
        while resp.is_open():
            char = sys.stdin.read(1)
            resp.update()
            if resp.is_open():
                resp.write_stdin(char)

    # start thread, reading input and redirect it to container
    t = Thread(target=read, args=[])

    t.start()
    # container output to sys.stdout
    while resp.is_open():
        data = resp.read_stdout(10)
        if resp.is_open():
            if len(data or "")>0:
                sys.stdout.write(data)
                sys.stdout.flush()
