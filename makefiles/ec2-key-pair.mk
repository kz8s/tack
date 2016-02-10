$(DIR_KEY_PAIR)/: ; mkdir -p $@

$(DIR_KEY_PAIR)/$(AWS_EC2_KEY_NAME).pem: | $(DIR_KEY_PAIR)/
	aws --region ${AWS_REGION} ec2 create-key-pair \
		--key-name ${AWS_EC2_KEY_NAME} \
		--query 'KeyMaterial' \
		--output text \
	> $@
	chmod 400 $@
	ssh-add $@

.PHONY: create-key-pair
create-key-pair: ## create ec2 key-pair and add to authentication agent
create-key-pair: $(DIR_KEY_PAIR)/$(AWS_EC2_KEY_NAME).pem

.PHONY: delete-key-pair
delete-key-pair: ## delete ec2 key-pair and remove from authentication agent
delete-key-pair:
	aws --region ${AWS_REGION} ec2 delete-key-pair \
		--key-name ${AWS_EC2_KEY_NAME}
	ssh-add -L |grep "${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem" \
		> ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub
	[ -s ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub ] &&\
	 	ssh-add -d ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pub
	rm -rf $(DIR_KEY_PAIR)/
