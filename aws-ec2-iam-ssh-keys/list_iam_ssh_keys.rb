#!/usr/bin/env ruby

require 'aws-sdk'

# Why does client need a region when IAM is global?
iam = Aws::IAM::Client.new(region: 'es-west-2')

iam.list_ssh_public_keys(user_name: 'test').ssh_public_keys.first.ssh_public_key_id
iam.get_ssh_public_key(ssh_public_key_id: 'APKAIGJ66MVKZA7JGONQ', encoding: 'SSH', user_name: 'test')

ssh_keys = []

# Yeah, this is super slow as we need to loop through every user and their key.
# If you're _seriously_ thinking about using this, have this run periodically as
# a lamba task and store the public key set in S3, and replace this with a
# script that checks against the output of that.
# TODO error handling
iam.get_group(group_name: 'ssh_users').users.each do |user|
  iam.list_ssh_public_keys(user_name: user.user_name).ssh_public_keys.each do |ssh_public_key|
    ssh_keys << iam.get_ssh_public_key(
      encoding: 'SSH',
      user_name: user.user_name,
      ssh_public_key_id: ssh_public_key.ssh_public_key_id
    ).ssh_public_key.ssh_public_key_body
  end
end

puts ssh_keys
