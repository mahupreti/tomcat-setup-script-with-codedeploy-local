#!/bin/bash

set -e

DEPLOY_TO_ROOT='true'
WAR_STAGED_LOCATION="demo-0.0.1-SNAPSHOT.war"

CATALINA_DIR="/home/ec2-user"
TOMCAT_VERSION_NUMBER=9.0.78

# In Tomcat, ROOT.war maps to the server root
if [[ "$DEPLOY_TO_ROOT" = 'true' ]];
then
    CONTEXT_PATH='ROOT'
fi

# Remove unpacked application artifacts
if [[ -f "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war" ]];
then
   rm "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war"
fi
if [[ -d "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}" ]];
then
   rm -rf "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}"
fi

# Copy the WAR fsile to the webapps directory
cp "${WAR_STAGED_LOCATION}" "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war"
