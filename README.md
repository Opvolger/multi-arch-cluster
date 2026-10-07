# Setup Cluster

First run ansible playbook in playbook directory see [README.md](playbook/README.md)

## Attach to server

```bash
# quake 2
kubectl attach -it -n games deploy/basm-quake2

# minecraft
kubectl attach -it -n games deploy/basm-minecraft
 ```

## metallb images

```bash
git clone -b v0.16.1 https://github.com/metallb/metallb.git
cd metallb
docker buildx build --platform linux/amd64,linux/arm64,linux/riscv64 --tag opvolger/metallb-controller:v0.16.1  --push --file controller/Dockerfile .
docker buildx build --platform linux/amd64,linux/arm64,linux/riscv64 --tag opvolger/metallb-speaker:v0.16.1  --push --file speaker/Dockerfile .
```

## Game - Factorio

Factorio is installed with `k0s_helm_install.yaml` ([factorio-server-charts](https://github.com/SQLJames/factorio-server-charts), values: [playbook/templates/helm/factorio.yaml](playbook/templates/helm/factorio.yaml)), the PersistentVolumeClaim for the saves is in [playbook/files/factorio.yaml](playbook/files/factorio.yaml) (`k0s_install_yaml_in_cluster.yaml`).

- fixed IP (MetalLB): `192.168.8.53` (default port `34197`)
- only amd64 nodes (nuc and supermicro): on arm64 the image runs factorio with box64, this fails on the rp5 (kernel with 16K page size) and the rp3b is too slow. There is no riscv64 image.
- the chart has an `affinity` value, but it is not used in the deployment, only `nodeSelector` works.
- image tag is the same version as steam (save game version), update `image.tag` when steam is updated.
- admins are in `admin_list` of the values (`/promote` in game is lost after a restart).
- changes in the settings (values or secret) are only used after a restart of the pod, the chart doesn't restart it: `kubectl rollout restart -n games deploy/basm-factorio`

### Account secret

The factorio.com username and token (not the password) are in an existing secret, find your token on [factorio.com/profile](https://factorio.com/profile). Create it before running the playbook (the pod waits for it):

```bash
kubectl create secret generic factorio-account -n games \
  --from-literal=username=my-factorio-username \
  --from-literal=token=0123456789abcdef0123456789abcdef
```

### Game password secret

The password to join the game is in an existing secret (key `game_password`, `serverPassword.passwordSecret` in the values):

```bash
kubectl create secret generic factorio-password -n games \
  --from-literal=game_password='MyGamePassword!'
```

### Import save game from steam

Steam (linux) keeps the saves in `~/.factorio/saves`. The chart has a save importer (init container), a `.zip` in `/factorio/save-importer/import` is copied to `/factorio/saves/<save_name>.zip` (`factorioServer.save_name`, now `wegrenner`) on the next start.

```bash
# copy the save game to the import directory of the running pod
kubectl exec -n games deploy/basm-factorio -c basm-factorio -- mkdir -p /factorio/save-importer/import
POD=$(kubectl get pod -n games -l app=basm-factorio -o jsonpath='{.items[0].metadata.name}')
kubectl cp ~/.factorio/saves/wegrenner.zip games/${POD}:/factorio/save-importer/import/wegrenner.zip -c basm-factorio
# restart, the save importer copies it to /factorio/saves/wegrenner.zip
kubectl rollout restart -n games deploy/basm-factorio
# check, should show "Loading map /factorio/saves/wegrenner.zip"
kubectl logs -n games deploy/basm-factorio -c import-factorio-save
kubectl logs -n games deploy/basm-factorio -c basm-factorio | grep -E 'Loading map|InGame'
```

The save `wegrenner` is without Space Age (`factorioServer.enable_space_age: false`), set it to `true` for a Space Age save game.

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
