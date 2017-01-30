#!/bin/bash
dir=${PWD##*/}

terraform remote config\
    -backend=s3\
    -backend-config="region=eu-west-2"\
    -backend-config="bucket=xono-terraform-state"\
    -backend-config="key=$dir/terraform.tfstate"\
    -backend-config="encrypt=true"\
    -pull=true
