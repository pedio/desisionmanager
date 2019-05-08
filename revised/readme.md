# Scripts below will be apply for automation process 

## Part One - Synchronization setup
# step 1
# initinal the DM project to sync changes to remote git (Stash Git) by git-hooks
# once performed, every change in DM project will sync to remote git
synctogit.sh
Usage: synctogit.sh MySpace projectname remotegit

## Part Two - Daily Sync source from Git back to workbench
# step 1
# restore the project sources from remote git
# the main purpose to sync the tagged version (updated version in pom.xml on remote git by pipeline)
restoreproject.sh
Usage: restoreproject.sh MySpace projectname remotegit

## Part Three - SIT build and deploy
# step 1
# download the sources from Git (Stash git) and compile by maven
# the packaged kjar will be upload to maven repo snapshot on SIT
build.sh
Usage: buildsit.sh remotegit

e.g.
/data/jboss-ruleengine/scripts/buildsit.sh rule-engine

# step 2
# deploy the compiled kjar to execution servers
deploy.sh
Usage: deploysit.sh jarfile

e.g.
/data/jboss-ruleengine/scripts/deploysit.sh /data/jboss-ruleengine/jboss-eap-7.2/guvnor-m2repo/mortgage-process/redhatdemo/1.0.1/redhatdemo-1.0.1.jar

## Part Four - UAT build and deploy
# step 1
# download the sources from Git (Stash git) and compile by maven
# the packaged kjar will be upload to maven repo release on UAT
build.sh
Usage: builduat.sh remotegit

e.g.
/data/jboss-ruleengine/scripts/builduat.sh rule-engine

# step 2
# deploy the compiled kjar to execution servers
deploy.sh
Usage: deployuat.sh jarfile

e.g.
/data/jboss-ruleengine/scripts/deployuat.sh /data/jboss-ruleengine/jboss-eap-7.2/guvnor-m2repo/mortgage-process/redhatdemo/1.0.1/redhatdemo-1.0.1.jar

## Part Five - PRD build and deploy
# step 1
# download the sources from Git (Stash git) and compile by maven
# the packaged kjar will be upload to maven repo release on PRD
build.sh
Usage: buildprd.sh remotegit

e.g.
/data/jboss-ruleengine/scripts/buildprd.sh rule-engine

# step 2
# deploy the compiled kjar to execution servers
deploy.sh
Usage: deployprd.sh jarfile

e.g.
/data/jboss-ruleengine/scripts/deployprd.sh /data/jboss-ruleengine/jboss-eap-7.2/guvnor-m2repo/mortgage-process/redhatdemo/1.0.1/redhatdemo-1.0.1.jar

