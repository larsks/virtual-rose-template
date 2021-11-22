To retrieve random password for `centos` user:

```
oc get vm your-vm-name \
  -o jsonpath='{.spec.template.spec.volumes[0].cloudInitConfigDrive.userData}'
```

Which might return something like:

```
#cloud-config
user: centos
password: abcd-1234-wxyz
chpasswd:
  expire: false
```
