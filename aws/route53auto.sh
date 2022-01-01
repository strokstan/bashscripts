#!/bin/bash
# Extract information about the Instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)
MY_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4/)

# Extract tags associated with instance
ZONE_TAG=$(aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_ZONE`].Value' --output text)
NAME_TAG1=$(aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_NAME1`].Value' --output text)
NAME_TAG2=$(aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_NAME2`].Value' --output text)

# Update Route 53 Record Set based on the Name tag to the current Public IP address of the Instance
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_TAG --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME_TAG1'","Type":"A","TTL":300,"ResourceRecords":[{"Value":"'$MY_IP'"}]}}]}'
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_TAG --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME_TAG2'","Type":"A","TTL":300,"ResourceRecords":[{"Value":"'$MY_IP'"}]}}]}'

#/opt/certbot/certbot-auto renew

