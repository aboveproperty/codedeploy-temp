#!/bin/bash 

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin
URL="http://169.254.169.254/latest"
ID=$(curl -s $URL/meta-data/instance-id)
MY_REGION=$(curl -s $URL/dynamic/instance-identity/document |jq -r .region)
export AWS_DEFAULT_REGION=$MY_REGION
ASG=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ID" | jq -r '.Tags[] | select(.["Key"] == "aws:autoscaling:groupName") | .Value')

#if [[ $ASG != *splunk* ]]; then
#    service splunk stop
#    update-rc.d splunk disable
#fi

/bin/rm -rf /var/lib/tomcat7/webapps/ROOT*
/bin/rm -rf /opt/abvprp/apache-tomcat/webapps/ROOT*

sleep 10
