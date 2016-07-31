#!/bin/bash
exec > >(tee /var/log/validateService.log)

. $(dirname $0)/common_functions.sh

IID=$(get_instance_id)

# This function implicitly sets $ELB_LIST
get_elb_list $IID 2>/dev/null

# Give tomcat a bit of time to start up
sleep 60

# Start out waiting for 60 seconds for the instance to become healthy. Do that
# ten times in a row before we give up and declare the deployment a failure.

NEXT_WAIT=60
until  [ $NEXT_WAIT -eq 70 ]
do
  if [ $(curl -m 5 --connect-timeout 5 -ssI http://localhost:8080/rest/system/ping | awk '{ if (/^HTTP/) {print $2}}') == '200' ]
  then
    echo "In Service at $(date)"
    exit 0
  else
    echo "sleeping $NEXT_WAIT at $(date)"
    sleep $(( NEXT_WAIT++ ))
  fi
done

error_exit "Failed to pass health check for $IID at $(date)"

# Note:
#
# I'd rather do this, and wait until the instance passes the ELB health
# check before declaring success. But on boot into an ASG, CodeDeploy
# is inserted after the instance enters Pending:Wait, and before it
# enters InService, so we're not actually marked as part of the ASG
# until CodeDeploy finishes. Therefore we can't use this check on newly
# booted instances until I can work around that scenario.
#
# until  [ $NEXT_WAIT -eq 70 ]
# do
#   if [ $(get_instance_health_elb $IID $ELB_LIST 2>/dev/null) == 'InService' ]
#   then
#     echo "In Service at $(date)"
#     exit 0
#   else
#     echo "sleeping $NEXT_WAIT"
#     sleep $(( NEXT_WAIT++ ))
#   fi
# done
#

