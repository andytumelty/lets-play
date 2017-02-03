#!/bin/bash

# FIXME sanitize
user=$1

# Return the user's SSH keys
while read ssh_public_key_id; do
  aws iam get-ssh-public-key \
    --user-name "$user" \
    --ssh-public-key-id "$ssh_public_key_id" \
    --encoding SSH \
    --query "SSHPublicKey.SSHPublicKeyBody" \
    --output text
done <<< "$(aws iam list-ssh-public-keys \
  --user-name "$user" \
  --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" \
  --output text
)"
