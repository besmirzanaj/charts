# ripe-atlas-probe

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

# RIPE-NCC atlas probe helm chart

This helm chart will install a RIPE NCC [software atlas probe](https://www.ripe.net/analyse/internet-measurements/ripe-atlas/host-a-probe/#software-probes). Packages [here](https://atlas.ripe.net/docs/howtos/software-probes.html)

This chart will also create the neccessary ssh keys for the probe usage and then to upload these onto the RIPE Atlas portal. After running this chart, copy the public key generated by the key generation job and copy it over on the Atlas probe creation screen at https://atlas.ripe.net/apply/swprobe/.

If you already have a software probe, you can reuse it and just add the generated public key in the "Update SSH key" section of the probe.

## How to install the chart

### Generic install

The default CSI will be used to create the atlas probe status volume.

```
helm install ripe-atlas-probe ripe-atlas-probe \
  --namespace ripe-atlas-probe --create-namespace
```

### Specifying the Storage CSI

```
helm upgrade -i ripe-atlas-probe ripe-atlas-probe \
  --namespace ripe-atlas-probe --create-namespace \
  --set persistentVolumeClaim.storageClass="nfs-csi"
```

### Skip creating the ssh key pair

If you already have some ssh keypair files tha tyou want to reuse, then you can run the following first to install the chart:

```
helm install ripe-atlas-probe ripe-atlas-probe \
  --namespace ripe-atlas-probe --create-namespace \
  --set persistentVolumeClaim.storageClass="nfs-csi" \
  --set job.sshKeyGen.enabled=false
```

Then you can import the sshe keypair assuming these are named `probe_key` and `probe_key.pub`:

```
kubectl create secret generic ssh-keypair \
  --from-file=probe_key=/tmp/probe_key \
  --from-file=probe_key.pub=/tmp/probe_key.pub \
  -n ripe-atlas-probe --dry-run=client -o yaml | kubectl apply -f -
```

## Uploading the secret the Atlas portal

The generated public ssh key is available at the following secret:

```
kubectl get secret --namespace ripe-atlas-probe ripe-atlas-secret -o jsonpath="{.data.probe_key\.pub}" | base64 -d
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| env[0].name | string | `"RXTXRPT"` |  |
| env[0].value | string | `"yes"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"docker.io/jamesits/ripe-atlas"` |  |
| image.tag | string | `"latest"` |  |
| job.sshKeyGen.enabled | bool | `true` |  |
| persistentVolumeClaim.accessMode | string | `"ReadWriteMany"` |  |
| persistentVolumeClaim.name | string | `"atlas-ripe-status"` |  |
| persistentVolumeClaim.size | string | `"512Mi"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"1"` |  |
| resources.limits.memory | string | `"64Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `true` |  |
| securityContext.capabilities.add[0] | string | `"NET_ADMIN"` |  |
| securityContext.capabilities.add[1] | string | `"SYS_TIME"` |  |
| securityContext.capabilities.add[2] | string | `"SYS_ADMIN"` |  |
| volumeMounts[0].mountPath | string | `"/var/atlas-probe/etc/probe_key"` |  |
| volumeMounts[0].name | string | `"ripe-atlas-key"` |  |
| volumeMounts[0].readOnly | bool | `false` |  |
| volumeMounts[0].subPath | string | `"probe_key"` |  |
| volumeMounts[1].mountPath | string | `"/var/atlas-probe/etc/probe_key.pub"` |  |
| volumeMounts[1].name | string | `"ripe-atlas-key"` |  |
| volumeMounts[1].readOnly | bool | `false` |  |
| volumeMounts[1].subPath | string | `"probe_key.pub"` |  |
| volumeMounts[2].mountPath | string | `"/var/atlas-probe/status/"` |  |
| volumeMounts[2].name | string | `"atlas-ripe-status"` |  |
| volumes[0].name | string | `"atlas-ripe-status"` |  |
| volumes[0].persistentVolumeClaim.claimName | string | `"atlas-ripe-status"` |  |
| volumes[1].name | string | `"ripe-atlas-key"` |  |
| volumes[1].secret.secretName | string | `"ripe-atlas-secret"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
