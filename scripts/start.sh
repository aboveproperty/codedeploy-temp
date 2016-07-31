#!/bin/bash

if [ -f /etc/sv/tomcat7/run ]; then
    START_CMD="sv start tomcat7"
else
    START_CMD="service tomcat7 start"
fi

$START_CMD
