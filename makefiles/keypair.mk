$(DIR_KEY_PAIR)/: ; mkdir -p $@

$(DIR_KEY_PAIR)/$(AWS_EC2_KEY_NAME).pem: | $(DIR_KEY_PAIR)/
	aws --region ${AWS_REGION} ec2 create-key-pair \
		--key-name ${AWS_EC2_KEY_NAME} \
		--query 'KeyMaterial' \
		--output text \
	> $@
	chmod 400 $@
	ssh-add $@

## create ec2 key-pair and add to authentication agent
create-keypair: $(DIR_KEY_PAIR)/$(AWS_EC2_KEY_NAME).pem

## delete ec2 key-pair and remove from authentication agent
delete-keypair:
	# todo: rework this delete logic
	aws --region ${AWS_REGION} ec2 delete-key-pair --key-name ${AWS_EC2_KEY_NAME} || true
	ssh-add -L | grep "${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem" > ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub || true
	if [ -s ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub ]; then \
		ssh-add -d ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub; \
	fi;
	@-rm -rf $(DIR_KEY_PAIR)/

.PHONY: create-key-pair delete-key-pair
