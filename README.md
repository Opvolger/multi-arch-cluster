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

## Install Games

```bash
# create namespace (if not exists)
kubectl create namespace games --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f quake2.yaml
kubectl apply -f minecraft.yaml
```

Attach to server

```bash
# quake 2
kubectl attach -it -n games deploy/basm-quake2

# minecraft
kubectl attach -it -n games deploy/basm-minecraft
 ```

## Install Jenkins

waiting for [k8s-sidecar RISCV64 support](https://github.com/kiwigrid/k8s-sidecar/pull/580)

```bash
git clone https://github.com/Opvolger/k8s-sidecar.git
cd k8s-sidecar
git checkout add-riscv64-support
docker buildx build . --platform linux/amd64,linux/arm64,linux/riscv64 --tag opvolger/k8s-sidecar:2.7.3  --push
```

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
kubectl create namespace jenkins
helm install jenkins jenkins/jenkins -n jenkins --values jenkins_values.yaml
```

## Octopus Deploy

find your license: [octopus](https://billing.octopus.com/)

```bash
export YOUR_OCTOPUS_LICENSE=[here your base64 string]
helm upgrade my-octopus-instance oci://ghcr.io/octopusdeploy/octopusdeploy-helm \
--install \
--namespace octopus-deploy \
--create-namespace \
--set octopus.acceptEula="Y" \
--set mssql.enabled="true" \
--set octopus.licenseKeyBase64="${YOUR_OCTOPUS_LICENSE}" \
--values octopus_values.yaml
```

local deploy (own code with fix):

```bash
helm upgrade my-octopus-instance ~/code/octopus-helm-charts/charts/octopus-deploy --install --namespace octopus-deploy --create-namespace --set octopus.acceptEula="Y" --set mssql.enabled="true" --set octopus.licenseKeyBase64="${YOUR_OCTOPUS_LICENSE}" --values octopus_values.yaml
```
