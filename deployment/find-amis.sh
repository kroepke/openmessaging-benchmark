#!/bin/sh

# use this to re-create the terraform AMI input vars in case the base image changes (or you are using some special region)

for region in $(aws ec2 describe-regions --query "Regions[].{Name:RegionName}"  --output text) ; do
	image=$(aws ec2 describe-images --owners 309956199498 --query 'Images[].ImageId' --filters "Name=name,Values=RHEL-7.8*GA*" --region $region --output text) 
	echo "\"$region\":\"$image\"" ;
done
