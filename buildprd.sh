#!/bin/bash
! [ $# -eq 1 ] && echo "Usage: ./build.sh remotegit" && exit 1

REGIONIONAL_RULES_WORKBENCH=ssh://git@aiahk-stash.aia.biz:7999/rhdm
REMOTEGIT=$1
TARGETGIT=$REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git
GUVNORM2REPO=/data/jboss-ruleengine/jboss-eap-7.2-uat/guvnor-m2repo/

echo "Pull sources from remote Git $TARGETGIT"
TMPTARGET="/tmp/$REMOTEGIT/$(date +%Y%m%d)"
rm -rf $TMPTARGET
mkdir -p $TMPTARGET
cd $TMPTARGET
git clone $TARGETGIT

echo "######## build and package project ##############"
cd $TMPTARGET/$REMOTEGIT
mvn package -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

echo "#### deploy compiled project to maven guvnor-m2repo ####"
MAVENPATH="$TMPTARGET/$REMOTEGIT/pom.xml"
GROUPID=$(cat $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep groupId |awk -F= '{print $2}')
ARTIFACTID=$(cat $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep artifactId |awk -F= '{print $2}')
VERSION=$(cat $MAVENPATH | /data/jboss-ruleengine/scripts/readpom.py | grep version |awk -F= '{print $2}') 
GROUPPATH=$(echo $GROUPID |tr '.' '/')
TMPSTR=$( date +%s)

echo $GROUPID
echo $ARTIFACTID
echo $VERSION
echo $GROUPPATH
echo $TMPSTR

#echo "putting the binary into decision central"
JARFILE=$TMPTARGET/$REMOTEGIT/target/$ARTIFACTID-$VERSION.jar
mvn deploy:deploy-file -DgroupId=$GROUPID -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dpackaging=jar -Dfile=$JARFILE -Durl=http://localhost:38280/decision-central/maven2  -DrepositoryId=guvnor-m2-repo-prd  -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

#mkdir -p $GUVNORM2REPO/$GROUPPATH/$NAMESPACE/$ARTIFACTID/$VERSION/
#cp $TMPTARGET/$REMOTEGIT/target/$ARTIFACTID-$VERSION.jar $GUVNORM2REPO/$GROUPPATH/$NAMESPACE/$ARTIFACTID/$VERSION/$ARTIFACTID-$VERSION-$TMPSTR.jar
#cp $TMPTARGET/$REMOTEGIT/pom.xml $GUVNORM2REPO/$GROUPPATH/$NAMESPACE/$ARTIFACTID/$VERSION/$ARTIFACTID-$VERSION-$TMPSTR.pom




