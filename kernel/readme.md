# Build kernel 6.19 for VisionFive 2 Lite

This kernel can be used for k0s Kubernetes (alle modules needed are there).
This build has a patched version of `pcie-starfive.c` so that the PCI-e is working (nvme)
This kernel can work with Debian Installer. (backed in modules)
This kernel can work with AMDGPU in the PCI-e (+ adapter for nvme)

This build in docker!

```bash
docker compose build
docker compose up
```
