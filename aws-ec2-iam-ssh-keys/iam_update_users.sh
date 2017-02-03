#!/bin/bash

# Get all users in the ssh_users group and make sure they exist
while read user; do
  # If the user doesn't exist, create
  if ! id "$user" >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G wheel "$user"
    echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
  fi
done <<< "$(aws iam get-group \
  --group-name ssh_users \
  --query "Users[].[UserName]" \
  --output 'text'
)"
