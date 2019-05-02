#!/bin/bash
if [ -z "$3" ]
  then
    echo "Not enough argument supplied"
    echo "e.g: ./restoreproject.sh namespace project remotegit"
    exit 1
fi
REGIONIONAL_RULES_WORKBENCH=ssh://git@aiahk-stash.aia.biz:7999/rhdm
NAMESPACE=$1
PROJECT=$2
REMOTEGIT=$3
TARGET=$REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git

echo "Remote existing project $PROJECT from $NAMESPACE"
curl -u 'rhdmAdmin:redh@T123' -H "accept: application/json" -H "content-type: application/json" -X DELETE "http://hkdcwtlbrm010:38080/decision-central/rest/spaces/$NAMESPACE/projects/$PROJECT"

echo ""
echo "...waiting for project clean up..."
while [ -d "/opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/$NAMESPACE/$PROJECT.git" ]
do sleep 5
done

echo "Restore project $PROJECT to $NAMESPACE from remote Git $TARGET"
TMPTARGET=/tmp/$NAMESPACE/$PROJECT/$(date +%Y%m%d)
rm -rf $TMPTARGET
mkdir -p $TMPTARGET
cd $TMPTARGET
git clone $REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git

echo "###Import project from remote Git###"
#echo  '{ "name": "'$PROJECT'", "description": "'$PROJECT'",  "userName": "svcasiamosbitrules",  "password": "NUxWjy3T", "gitURL": "'$TARGET'"}'
curl -u 'rhdmAdmin:redh@T123' -H "accept: application/json" -H "content-type: application/json" -X POST "http://hkdcwtlbrm010:38080/decision-central/rest/spaces/${NAMESPACE}/git/clone" -d '{ "name": "'$PROJECT'", "description": "'$PROJECT'",  "userName": "",  "password": "", "gitURL": "'$TMPTARGET/$REMOTEGIT'"}'

echo ""
echo "...waiting for project clone..."
while [ ! -d "/opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/$NAMESPACE/$PROJECT.git/hooks" ]
do sleep 5
done
cp -a /opt/jboss-ruleengine/jboss-eap-7.2/git-hooks/post-commit /opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/$NAMESPACE/$PROJECT.git/hooks/

while [ ! -f "/opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/$NAMESPACE/$PROJECT.git/config" ]
do sleep 5
done
sed -i "s/url = .*/url = ssh:\/\/git@aiahk-stash.aia.biz:7999\/rhdm\/$REMOTEGIT.git/g" /opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/$NAMESPACE/$PROJECT.git/config

echo "...process completed..."
