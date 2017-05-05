
# If you use direnv, rename this file to .envrc, 
# this is so you can driving config for tack and aws using env vars

export AWS_PROFILE=env-account

#if this is set, provider in io.tf will use this value instead of AWS_PROFILE

# Uncomment the AWS_SOURCE_PROFILE export to use a delegate account, eg aws organisations. 
# This is because terraform doesn't refer to the config, only credentials, so it can't 
# see any keys for a delegate account since the parent account profile is used to login
# there are none for a subaccount, you need to point at a config with  source_profile or 
# role_arn values.

#export AWS_SOURCE_PROFILE=root-acc

export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=$AWS_REGION
export CLUSTER_NAME=xxxxxx
export ETCD_IPS=10.0.10.10
export HYPERKUBE_TAG ?= v1.5.1_coreos.0
