#!/usr/bin/env python
import boto3

client = boto3.client('iam')
keys = []

for user in client.get_group(GroupName='ssh_users')['Users']:
    ssh_public_keys = client.list_ssh_public_keys(
        UserName=user['UserName']
    )['SSHPublicKeys']
    for ssh_public_key in ssh_public_keys:
        keys.append(
            client.get_ssh_public_key(
                UserName=user['UserName'],
                SSHPublicKeyId=ssh_public_key['SSHPublicKeyId'],
                Encoding='SSH'
            )['SSHPublicKey']['SSHPublicKeyBody']
        )

for key in keys:
    print key
