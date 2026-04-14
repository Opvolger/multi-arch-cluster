# Setup Cluster

First run ansible playbook in playbook directory see [README.md](playbook/README.md)
Then apply the next commands

```bash
# dashboard for traefic
kubectl apply -f dashboard.yaml
# ip-pool for metallb
kubectl apply -f ip-pool.yaml
kubectl apply -f smb.yaml
# username / password for samba share
kubectl create secret generic smbcreds --from-literal username=persistentvolume --from-literal password="Ab12345!" -n kube-system
```
