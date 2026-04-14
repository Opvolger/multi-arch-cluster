# Setup Cluster

First run ansible playbook in playbook directory.
Then apply the next commands

```bash
kubectl apply -f dashboard.yaml
```

## Setup RISC-V node(s)

I build k0s-riscv64 on a RISC-V board (Starfive VisionFive 2) with Debian and go and docker installed. Copied k0s-riscv64 to my main machine and started the setup.

How to setup Debian on this board is already on my blog. I made a user opvolger and enabled the SSH server.

## Setup ARM64 node(s)

I used raspberry pi's for this, a 3B+ and a 5. I Flashed the SD cards with the `Raspberry Pi Images v2.0.7`, used the Raspberry Pi OS (64-bit). Setup the user (opvolger) enabled SSH-Server.

If you want to use the UART for debugging the boot process, you can enable it:

Append following line to /boot/config.txt

```ini
[all]
enable_uart=1
```

For Kubernetes you will need `cgroup_memory` enabled. I added this to my boot command.

Append following line to /boot/firmware/cmdline.txt

```ini
cgroup_memory=1 cgroup_enable=memory
```

## Setup AMD64 node(s)

Just used a Debian iso to boot, added the SSH server, created a login voor the user opvolger

## HAProxy

Read [high-availability](https://docs.k0sproject.io/v1.35.2+k0s.0/high-availability/) in k0sproject

Installed HAProxy in the LuCI

logged in to the router edit `/etc/haproxy.cfg` with vi and added:

```ini
frontend kubeAPI
    bind :6443
    mode tcp
    default_backend kubeAPI_backend
frontend konnectivity
    bind :8132
    mode tcp
    default_backend konnectivity_backend
frontend controllerJoinAPI
    bind :9443
    mode tcp
    default_backend controllerJoinAPI_backend

backend kubeAPI_backend
    mode tcp
    server k0s-controller1 192.168.8.10:6443 check check-ssl verify none
    server k0s-controller2 192.168.8.11:6443 check check-ssl verify none
    server k0s-controller3 192.168.8.12:6443 check check-ssl verify none
backend konnectivity_backend
    mode tcp
    server k0s-controller1 192.168.8.10:8132 check check-ssl verify none
    server k0s-controller2 192.168.8.11:8132 check check-ssl verify none
    server k0s-controller3 192.168.8.12:8132 check check-ssl verify none
backend controllerJoinAPI_backend
    mode tcp
    server k0s-controller1 192.168.8.10:9443 check check-ssl verify none
    server k0s-controller2 192.168.8.11:9443 check check-ssl verify none
    server k0s-controller3 192.168.8.12:9443 check check-ssl verify none

listen stats
   bind *:9000
   mode http
   stats enable
   stats uri /
```

Now i have a stats page on [http://192.168.8.1:9000](http://192.168.8.1:9000)
