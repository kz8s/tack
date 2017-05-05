
# Essential for LABDigital approach, set this

export AWS_PROFILE=bp-pip-dev

#if this is set, provider in io.tf will use this value instead of AWS_PROFILE

#this is because terraform doesn't refer to the config, only credentials, so it can't see any keys since there are none for bp-pip-dev, only for bp-root, 
#and it does not see the source_profile or role_arn values in config.
export AWS_SOURCE_PROFILE=bp-root

export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=$AWS_REGION
export CLUSTER_NAME=bp-pip-dev
export ETCD_IPS=10.0.10.10
HYPERKUBE_TAG ?= v1.5.1_coreos.0
#export HYPERKUBE_TAG=v1.6.0_coreos.0