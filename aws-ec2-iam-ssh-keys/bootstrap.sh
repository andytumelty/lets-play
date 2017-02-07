#!/bin/bash

aws s3 --region eu-west-2 cp s3://${bootstrap}/aws-ec2-iam-ssh-keys/iam_update_users.sh /usr/local/bin/
aws s3 --region eu-west-2 cp s3://${bootstrap}/aws-ec2-iam-ssh-keys/iam_check_keys.sh /usr/local/bin/
chmod +x /usr/local/bin/iam_check_keys.sh
chmod +x /usr/local/bin/iam_update_users.sh

/usr/local/bin/iam_update_users.sh

echo '*/5 * * * * root /usr/local/bin/iam_update_users.sh' > /etc/cron.d/iam_update_users

sed -i 's@.*AuthorizedKeysCommand .*@AuthorizedKeysCommand /usr/local/bin/iam_check_keys.sh@' /etc/ssh/sshd_config
sed -i 's@.*AuthorizedKeysCommandUser .*@AuthorizedKeysCommandUser root@' /etc/ssh/sshd_config
service sshd restart
