# Setup Cluster

First run ansible playbook in playbook directory see [README.md](playbook/README.md)

## Attach to server

```bash
# quake 2
kubectl attach -it -n games deploy/basm-quake2

# minecraft
kubectl attach -it -n games deploy/basm-minecraft
 ```

## Jenkins

Jenkins is installed with `k0s_helm_install.yaml` (values: [playbook/templates/helm/jenkins.yaml](playbook/templates/helm/jenkins.yaml)).

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

fix for adding agent, add this in command, kubernetesMonitor can't spin up on riscv64 node.

```bash
--set kubernetesMonitor.nodeSelector."kubernetes\\.io/arch"=amd64 \
```
