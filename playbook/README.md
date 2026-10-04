# Playbook

```bash
# will crash 1ste time on install helm, network changes.
ansible-playbook k0s_init.yaml -i inventory/ --user opvolger --ask-pass --ask-become-pass -vv --limit "supermicro.cluster,"
# reboot system(s) and next run will hang on apply netplan!
ansible-playbook k0s_init.yaml -i inventory/ --user opvolger -vv --limit "supermicro.cluster,"
# change ip in inventory! and last run (set firewall trust on all machines)
ansible-playbook k0s_init.yaml -i inventory/ --user opvolger -vv
# reboot and update or install cluster
ansible-playbook k0s_install_update.yaml -i inventory/ --user opvolger -vv

# add some stuff in cluster (helm first: metallb, traefik and csi-driver-smb are needed for the yaml files)
ansible-playbook k0s_helm_install.yaml -i inventory/ --user opvolger -vv
ansible-playbook k0s_install_yaml_in_cluster.yaml -i inventory/ --user opvolger -vv

# reset
ansible-playbook k0s_reboot_cluster.yaml -i inventory/ --user opvolger -vv

# shutdown before power off the cluster!
ansible-playbook k0s_shutdown_cluster.yaml -i inventory/ --user opvolger -vv

# only setup netwerk for 1 machine
ansible-playbook k0s_setup_network.yaml -i inventory/ --user opvolger -vv --limit "supermicro.cluster,"

# run updates
ansible-playbook k0s_update_packages.yaml -i inventory/ --user opvolger -vv
```
