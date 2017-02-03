A simple set of scripts to create users from IAM, and authenticate SSH
connections against SSH keys stored in IAM (for AWS CodeCommit).

list_iam_ssh_keys.{py,rb} are experiments listing out all ssh keys, the actual
check is done in bash using the aws CLI

This isn't ideal:
- No central password management (unauthenticated sudo)
- Everyone in the ssh_users group has root access. If you get into finer group
  use then use AD/LDAP: it'll be easier to manage group mapping
- There's a notable delay when logging in (3-4 seconds). It might be worth
  experimenting whether once of the other SDKs is notably faster than using CLI
