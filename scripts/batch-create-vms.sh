#!/bin/bash

set -o errexit

for sshkey in *.pub; do
    username="${sshkey%.pub}"
    oc process rose-integrated-template -p NAME="${username}" -p SSHKEY="$(cat $sshkey)" |
        oc apply -f-

    # Get vm uid
    uid=$(oc get vm "${username}-vm" -o jsonpath='{.metadata.uid}')

    # Add ownerReference to service (this ensures the service gets deleted
    # if the vm gets deleted).
    oc patch service "${username}-vm-service" --type merge \
        -p '
        {
            "metadata": {
                "ownerReferences": [
                    {
                        "apiVersion": "kubevirt.io/v1",
                        "kind": "VirtualMachine",
                        "name": "'"${username}-vm"'",
                        "uid": "'"${uid}"'"
                    }
                ]
            }
        }'

    # I don't know if the ip address is guaranteed to be available
    # immediately or not, so we loop until we get a non-empty value.
    while :; do
        ip=$(oc get service "${username}-vm-service" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        [ -n "$ip" ] && break
        sleep 1
    done

    echo "$ip" > "${username}.ip"

    oc get vm "${username}-vm" \
        -o jsonpath='{.metadata.annotations.massopen\.cloud/password}' \
        > "${username}.password"
done
