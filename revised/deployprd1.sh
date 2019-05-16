#!/bin/bash
! [ $# -eq 1 ] && echo "Usage: ./deployprd1.sh jarfile" && exit 1
! [ -f $1 ] && echo "$1 file not found." && exit 1

KIESERVER=http://HKEQXPLBRM010:38080
echo $KIESERVER
CURRENTDIR=$(dirname $0)
JARFILE=$(readlink -f $1)
MAVENPATH=$($JAVA_HOME/bin/jar tf $JARFILE  |grep pom.xml |grep maven)
GROUPID=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep groupId |awk -F= '{print $2}')
ARTIFACTID=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep artifactId |awk -F= '{print $2}')
VERSION=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep version |awk -F= '{print $2}') 
GROUPPATH=$(echo $GROUPID |tr '.' '/')
TMPSTR=$( date +%s)
CONTAINERNAME=${ARTIFACTID}_${VERSION}

echo $GROUPID
echo $ARTIFACTID
echo $VERSION
echo $GROUPPATH
cd $CURRENTDIR

echo "Checking if there is existing containers"
RESULT=$(curl -s -H 'Content-Type: application/xml' -u 'rhdmAdmin:redh@T123'  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME |grep "is not instantiated.")

echo "Container Name: " $CONTAINERNAME
if  [ "x$RESULT" = "x" ]; then
   echo "$CONTAINERNAME already defined, will stop it and remove it"
   echo "Stopping container $CONTAINERNAME"
   curl -X PUT -s -u rhdmAdmin:redh@T123  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME/status/deactivated
   echo "Removing container $CONTAINERNAME"
   curl -s -u rhdmAdmin:redh@T123 -X DELETE $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME -H "accept: application/json"

   sleep 10
   echo "check again, if it didn't removed, will abort"
   RESULT_AGAIN=$(curl -s -H 'Content-Type: application/xml' -u 'rhdmAdmin:redh@T123'  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME |grep "is not instantiated.")
   if  [ "x$RESULT_AGAIN" = "x" ]; then
      echo "Failed to remove container, exiting with ERROR"
      exit -1
   fi
fi

CONTAINERXML=$(/data/jboss-ruleengine/scripts/createKSContainer.py $CONTAINERNAME $ARTIFACTID $GROUPID $VERSION)
curl -s -u rhdmAdmin:redh@T123 -X PUT $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME -H "accept: application/json" -H "content-type: application/xml" -d "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>$CONTAINERXML"

