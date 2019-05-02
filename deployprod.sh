#!/bin/bash
! [ $# -eq 2 ] && echo "Usage: ./deploy.sh jarfile kie-server" && exit 1
! [ -f $1 ] && echo "$1 file not found." && exit 1

KIESERVER=http://$2:38080

CURRENTDIR=$(dirname $0)
JARFILE=$(readlink -f $1)
MAVENPATH=$($JAVA_HOME/bin/jar tf $JARFILE  |grep pom.xml |grep maven)
GROUPID=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep groupId |awk -F= '{print $2}')
ARTIFACTID=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep artifactId |awk -F= '{print $2}')
VERSION=$(unzip -p $JARFILE $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep version |awk -F= '{print $2}') 
GROUPPATH=$(echo $GROUPID |tr '.' '/')
TMPSTR=$( date +%s)
GUVNORM2REPO=/data/jboss-ruleengine/jboss-eap-7.2/guvnor-m2repo/
CONTAINERNAME=${ARTIFACTID}_${VERSION}

echo $GROUPID
echo $ARTIFACTID
echo $VERSION
echo $GROUPPATH
cd $CURRENTDIR

#echo "putting the binary into decision central"
#mvn deploy:deploy-file -DgroupId=$GROUPID -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dpackaging=jar -Dfile=$JARFILE -Durl=http://10.145.83.47:8080/decision-central/maven2  -DrepositoryId=dm

echo "Checking if there is existing containers"
RESULT=$(curl -s -H 'Content-Type: application/xml' -u 'rhdmAdmin:redh@T123'  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME |grep "is not instantiated.")

echo $CONTAINERNAME

if  [ "x$RESULT" = "x" ]; then
   echo "$CONTAINERNAME already defined, will stop it and remove it"
   echo "Stopping container $CONTAINERNAME"
   curl -X PUT -s -u rhdmAdmin:redh@T123  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME/status/deactivated
   echo "Removing container $CONTAINERNAME"
   curl -X DELETE -s -H 'Content-Type: application/xml' -u rhdmAdmin:redh@T123  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME

   sleep 10
   echo "check again, if it didn't removed, will abort"
   RESULT_AGAIN=$(curl -s -H 'Content-Type: application/xml' -u 'rhdmAdmin:redh@T123'  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME |grep "is not instantiated.")
   if  [ "x$RESULT_AGAIN" = "x" ]; then
      echo "Failed to remove container, exiting with ERROR"
      exit -1
   fi
fi

RET=$(curl -s --write-out "%{http_code}\n" --output /dev/null -X PUT  -u rhdmAdmin:redh@T123 $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME -H "content-type: application/xml" -d $(/data/jboss-ruleengine/scripts/createKSContainer.py $CONTAINERNAME $ARTIFACTID $GROUPID $VERSION))

echo "Create result: $RET"
if [ "$RET" != "201" ]; then
   echo "Failed to create container exiting"
   exit -2
fi

echo "Starting containers"
#RET=$(curl  -s --write-out "%{http_code}\n" --output /dev/null -H 'Content-Type: application/xml' -X PUT -s -u rhdmAdmin:redh@T123  $KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME/status/activated)
#echo "Start result: $RET"
#if [ "$RET" != "200" ]; then
#   echo "Failed to start container exiting"
#   exit -3
#fi

echo "Checking container readiness"
CONTAINERLIST=$(curl -s -u rhdmAdmin:redh@T123  "$KIESERVER/kie-server/services/rest/server/containers/$CONTAINERNAME" -H "Content-Type: application/xml" | grep status)

echo $CONTAINERLIST

