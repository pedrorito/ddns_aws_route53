#!/bin/bash

#Variable Declaration
TYPE="A"
TTL=60

#get current IP address
IP=$(curl http://checkip.amazonaws.com/)

#validate IP address (makes sure Route 53 doesn't get updated with a malformed payload)
if [[ ! $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	exit 1
fi

#get current
aws route53 list-resource-record-sets --hosted-zone-id $AWS_HOSTED_ZONE_ID | jq -r '.ResourceRecordSets[] | select (.Name == "'"$AWS_RECORD_NAME"'") | select (.Type == "'"$TYPE"'") | .ResourceRecords[0].Value' > /tmp/current_route53_value

cat /tmp/current_route53_value

#check if IP is different from Route 53
if grep -Fxq "$IP" /tmp/current_route53_value; then
	echo "IP Has Not Changed, Exiting"
	exit 1
fi


echo "IP Changed, Updating Records"

#prepare route 53 payload
cat > /tmp/route53_changes.json << EOF
    {
      "Comment":"Updated From DDNS Shell Script",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$AWS_RECORD_NAME",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF

#update records
aws route53 change-resource-record-sets --hosted-zone-id $AWS_HOSTED_ZONE_ID --change-batch file:///tmp/route53_changes.json >> /dev/null