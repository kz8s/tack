apply-s3: get ; terraform apply -target module.s3

destroy-s3: ; terraform destroy -target module.s3

plan-s3: get ; terraform plan -target module.s3

test-s3:

.PHONY: apply-s3 destroy-s3 plan-s3 test-s3
