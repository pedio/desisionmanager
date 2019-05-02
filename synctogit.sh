#!/bin/bash
if [ -z "$3" ]
  then
    echo "Not enough argument supplied"
    echo "e.g: ./synctogit.sh namespace localgit rule-engine.git"
    exit 1
fi
REGIONIONAL_RULES_WORKBENCH=ssh://git@aiahk-stash.aia.biz:7999/rhdm
LOCALGIT_BASE=/opt/jboss-ruleengine/jboss-eap-7.2/bin/.niogit/
NAMESPACE=$1
LOCALGIT=$2
REMOTEGIT=$3
echo "Initialize local git $LOCALGIT_BASE/$NAMESPACE/$LOCALGIT.git with remote Git $REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git"


echo "#git clone from .nioget"
cd $LOCALGIT_BASE/$NAMESPACE/$LOCALGIT.git

git config --global user.name "dmserviceaccount"
git config --global user.email "dmserviceaccount@aia.com"

echo "# add remote origin to remote git"
git remote add origin $REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git
git remote set-url origin $REGIONIONAL_RULES_WORKBENCH/$REMOTEGIT.git

echo "# prepare hook file to remote master"
cp -a /opt/jboss-ruleengine/jboss-eap-7.2/git-hooks/post-commit $LOCALGIT_BASE/$NAMESPACE/$LOCALGIT.git/hooks

cd hooks
./post-commit
