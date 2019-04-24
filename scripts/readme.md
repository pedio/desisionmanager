# Scripts below will be apply for automation process 

# step 1
# initinal the DM project to sync changes to remote git (Stash Git) by git-hooks
# once performed, every change in DM project will sync to remote git
synctogit.sh
Usage: synctogit.sh MySpace projectname remotegit

# step 2
# restore the project sources from remote git
# the main purpose to sync the tagged version (updated version in pom.xml on remote git by pipeline)
restoreproject.sh
Usage: restoreproject.sh MySpace projectname remotegit

# step 3
# download the sources from Git (Stash git) and compile by maven
# (to be defined) the packaged kjar will be upload to maven repo snapshot on SIT stage
# (to be defined) the packaged kjar will be upload to maven repo release on UAT/PROD stage
build.sh
Usage: build.sh remotegit targetmavenrepo

# step 4
# deploy the compiled kjar to execution servers
deploy.sh
Usage: deploy.sh jarfile kieserver

