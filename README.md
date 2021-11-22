# Virtual ROSE on MOC OpenShift

## Web console access

The [ocp-prod web console][console] is available at:

- https://console-openshift-console.apps.ocp-prod.massopen.cloud/

[console]: https://console-openshift-console.apps.ocp-prod.massopen.cloud/

## Command line access

1. Install the OpenShift [command line tools][cli].
2. From the [console][], click on your account name in the upper
   right and then select "[Copy login command][login]".
3. On the next page, select "Display Token"
4. Copy the command under "Log in with this token" (`oc login
   --token=...`)
5. Paste this into your terminal.

Note that the token expires daily, so you will need to regularly repeat steps
2-5.

[cli]: https://console-openshift-console.apps.ocp-prod.massopen.cloud/command-line-tools
[login]: https://oauth-openshift.apps.ocp-prod.massopen.cloud/oauth/token/request

## Creating virtual machines

The template `rose-integrated-template` will create:

- A virtual machine
- A [Service][] object exposing various services (ssh, http, https,
  rdp) on a public address

[service]: https://kubernetes.io/docs/concepts/services-networking/service/

You render the template using the `oc process` command and apply it to
your OpenShift project with the `oc apply` command.  For example, if
we want to create a virtual machine using an ssh public
key from the file `id_rsa.pub`, we could run:

```
oc process rose-integrated-template -p NAME=node1 -p SSHKEY="$(cat id_rsa.pub)" |
  oc apply -f-
```

This would create a virtual machine named `node1-vm` and a [Service][]
named `node1-vm-service`.

To delete the virtual machine and service we can just replace `oc
apply` with `oc delete`:

```
oc process rose-integrated-template -p NAME=node1 -p SSHKEY="$(cat id_rsa.pub)" |
  oc delete -f-
```

To see the public address assigned to the service, run the following
command:

```
oc get service node1-vm-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### Batch creation example

If you store student ssh public keys in files named `<username>.pub`,
you could automate the creation of all your virtual machines with a
script like this:

```
#!/bin/bash

for sshkey in *.pub; do
    username="${sshkey%.pub}"
    oc process rose-integrated-template -p NAME="${username}" -p SSHKEY="$(cat $sshkey)" |
        oc apply -f-

    # I don't know if the ip address is guaranteed to be available
    # immediately or not, so we loop until we get a non-empty value.
    while :; do
        ip=$(oc get service "${username}-vm-service" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        [ -n "$ip" ] && break
        sleep 1
    done

    echo "$ip" > "${username}.ip"

    oc get vm "${username}" \
       -o jsonpath='{ .metadata.annotations.massopen\.cloud/password }' \
        > "${username}.password"
done
```

This will create virtual machine and service named after the username.
The public ip address gets stored in `<username>.ip` and the password
for the `centos` user goes in `<username>.password`.

## Access using RDP

Due to circumstances beyond our control, RDP access on port 3389 is
currently blocked for virtual machines on the `ocp-prod` cluster. We
have exposed RDP access on port `3390` instead. You will need to
provide this port number when connecting.

## Password for CentOS user

For security reasons, when you create a new virtual machine from the
template a random password is generated for the `centos` user. You can
retrieve that password with the following command:

```
oc get vm <vm name> \
  -o jsonpath='{ .metadata.annotations.massopen\.cloud/password }'
```
