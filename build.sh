#!/bin/bash
export PATH=$PATH:/usr/local/apache-maven/bin/
#requires xmllint

CURRENTDIR=$(dirname $0)
JARFILE=$(readlink -f $1)
MAVENPATH=$(jar tf $JARFILE  |grep pom.xml |grep maven)
GROUPID=$(unzip -p $JARFILE $MAVENPATH | /data/jbossEAP/automation/readpom.py | grep groupId |awk -F= '{print $2}')
ARTIFACTID=$(unzip -p $JARFILE $MAVENPATH | /data/jbossEAP/automation/readpom.py | grep artifactId |awk -F= '{print $2}')
VERSION=$(unzip -p $JARFILE $MAVENPATH | /data/jbossEAP/automation/readpom.py | grep version |awk -F= '{print $2}') 
GROUPPATH=$(echo $GROUPID |tr '.' '/')
TMPSTR=$( date +%s)
CONTAINERNAME="demo"

echo $GROUPID
echo $ARTIFACTID
echo $VERSION
echo $GROUPPATH
cd $CURRENTDIR


echo "putting the binary into decision central"
mvn deploy:deploy-file -DgroupId=$GROUPID -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dpackaging=jar -Dfile=$JARFILE -Durl=http://10.145.83.47:8080/decision-central/maven2  -DrepositoryId=dm

echo "checking if there is existing containers"
RESULT=$(curl -s -H 'Content-Type: application/xml' -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME |grep "does not have container with id")

if  [ "x$RESULT" = "x" ]; then
   echo "$CONTAINERNAME already defined, will stop it and remove it"
   echo "Stopping container $CONTAINERNAME"
   curl -X POST -s -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME/status/stopped
   echo "Removing container $CONTAINERNAME"
   curl -X DELETE -s -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME


   sleep 10
   echo "check again, if it didn't removed, will abort"
   RESULT_AGAIN=$(curl -s -H 'Content-Type: application/xml' -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME |grep "does not have container with id")
   if  [ "x$RESULT_AGAIN" = "x" ]; then
      "Failed to remove container, exiting with ERROR"
      exit -1
   fi
fi

echo "Crating new containers"
RET=$(curl -s --write-out "%{http_code}\n" --output /dev/null -H 'Content-Type: application/xml' -XPUT -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME -d $(/data/jbossEAP/automation/createContainer.py $CONTAINERNAME $CONTAINERNAME $ARTIFACTID $GROUPID $VERSION))
echo "Create result: $RET"
if [ "$RET" != "201" ]; then
   echo "Failed to create container exiting"
   exit -2
fi

echo "starting containers"
RET=$(curl  -s --write-out "%{http_code}\n" --output /dev/null -H 'Content-Type: application/xml' -X POST -s -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/containers/$CONTAINERNAME/status/started)

echo "Start result: $RET"

if [ "$RET" != "200" ]; then
   echo "Failed to start container exiting"
   exit -3
fi

echo "checking container readiness"
CONTAINERLIST=$(curl -s -u rhdmAdmin:redh@T123  http://10.145.83.47:8180/decision-central/rest/controller/management/servers/default-kieserver/ | /data/jbossEAP/automation/readServerList.py)

TIMEUSED=0
for CONTAINERINSTANCE in $CONTAINERLIST;
do
   STATUS="STOPPED"
   while [ "x$STATUS" != "xSTARTED" ];
   do
     STATUS=$(curl -s -u kieuser:redh@T123  $CONTAINERINSTANCE/containers/$CONTAINERNAME |/data/jbossEAP/automation/readContainerStatus.py )
     echo "SERVER: $CONTAINERINSTANCE STATUS:  $STATUS"
     sleep 1
     TIMEUSED=$(( TIMEUSED +1 ))
     if [ "$TIMEUSED" -gt 30 ]; then
        echo "TIMEOUT!!!!!"
		exit -7
     fi
   done 
done
