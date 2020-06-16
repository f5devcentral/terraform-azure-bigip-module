#!/bin/bash

## ..:: Variables Definition ::..
## ----------------------------------------------------------------------------
LOG_FILE='${onboard_log}'
LIBS_DIR='${libs_dir}'


if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi
exec 1>$LOG_FILE 2>&1
# WAIT FOR BIG-IP SYSTEMS & API TO BE UP
curl -o /config/cloud/utils.sh -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/F5Networks/f5-cloud-libs/develop/scripts/util.sh
. /config/cloud/utils.sh
wait_for_bigip
### CHECK IF DNS IS CONFIGURED YET, IF NOT, SLEEP
echo "CHECK THAT DNS IS READY"
nslookup github.com
if [ $? -ne 0 ]; then
  echo "DNS NOT READY, SLEEP 30 SECS"
  sleep 30
fi

### DOWNLOAD ONBOARDING PKGS
# Could be pre-packaged or hosted internally
mkdir -p ${libs_dir}
DO_URL='${DO_URL}'
DO_FN=$(basename "$DO_URL")
AS3_URL='${AS3_URL}'
AS3_FN=$(basename "$AS3_URL")
TS_URL='${TS_URL}'
TS_FN=$(basename "$TS_URL")
FAST_URL='${FAST_URL}'
FAST_FN=$(basename "$FAST_URL")
CFE_URL='${CFE_URL}'
CFE_FN=$(basename "$CFE_URL")
echo -e "\n"$(date) "Download Declarative Onboarding Pkg"
curl -L -o ${libs_dir}/$DO_FN $DO_URL
sleep 20
echo -e "\n"$(date) "Download AS3 Pkg"
curl -L -o ${libs_dir}/$AS3_FN $AS3_URL
sleep 20
echo -e "\n"$(date) "Download TS Pkg"
curl -L -o ${libs_dir}/$TS_FN $TS_URL
sleep 20
echo -e "\n"$(date) "Download FAST Pkg"
curl -L -o ${libs_dir}/$FAST_FN $FAST_URL
sleep 20
echo -e "\n"$(date) "Download CFE Pkg"
curl -L -o ${libs_dir}/$CFE_FN $CFE_URL
sleep 20
# Copy the RPM Pkg to the file location
cp ${libs_dir}/*.rpm /var/config/rest/downloads/
# Install Declarative Onboarding Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$DO_FN\"}"
echo -e "\n"$(date) "Install DO Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA
# Install AS3 Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$AS3_FN\"}"
echo -e "\n"$(date) "Install AS3 Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA
# Install TS Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$TS_FN\"}"
echo -e "\n"$(date) "Install TS Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA
# Install FAST Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$FAST_FN\"}"
echo -e "\n"$(date) "Install FAST Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA
# Install CFE Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$CFE_FN\"}"
echo -e "\n"$(date) "Install CFE Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA
date
echo "FINISHED STARTUP SCRIPT"