#!/bin/bash
#tomcat_installation_dir="/home/mahesh/Desktop/projects/tomcat-codedeploy-test"

set -e

CATALINA_DIR="/home/mahesh"
#CATALINA_HOME='/home/mahesh/tomcat'
#PROJECT_HOME="/home/mahesh/Desktop/projects/tomcat-codedeploy-test/test"
TOMCAT_VERSION_NUMBER=9.0.78

DEPLOY_TO_ROOT='true'
WAR_STAGED_LOCATION="/home/mahesh/Desktop/projects/tomcat-codedeploy-test/demo-0.0.1-SNAPSHOT.war"

echo "Tomcat group and user are going to be created."
TOMCAT_GROUP="tomcat"
TOMCAT_USER="tomcat"

# Create the Tomcat group
if ! getent group "${TOMCAT_GROUP}" > /dev/null; then
    sudo groupadd "${TOMCAT_GROUP}"
fi

# Create the Tomcat user without login shell access
if ! getent passwd "${TOMCAT_USER}" > /dev/null; then
    sudo useradd -M -g "${TOMCAT_GROUP}" -s /usr/sbin/nologin "${TOMCAT_USER}"
fi

# Print a message indicating the successful creation of the group and user
echo "group and user got created successfully"

###created the viveka home directory (for what? i also have to ask)
#if [ -d "${PROJECT_HOME}" ];
#then
#  rm -rf ${PROJECT_HOME}
#  echo "removed PROJECT_HOME"
#  mkdir ${PROJECT_HOME}
#  echo "created PROJECT_HOME"
#else
#  mkdir ${PROJECT_HOME}
#fi

#
#######changed the owner group
#sudo chmod 755 -R ${PROJECT_HOME}
#sudo chown tomcat:tomcat -R ${PROJECT_HOME}
#echo "made the owner mahesh and changed the mode to 755"

##check if tomcat is already installed or not
if [[ -d "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}" ]];
then
    echo "Tomcat is installed at ${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
    echo "no need to download"
    sudo chmod 755 -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
    sudo chown tomcat:tomcat -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
else
    echo "Tomcat is not installed at ${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"

    ###download tomcat
    wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION_NUMBER}/bin/apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz
    ####extract tomcat
    sudo tar -xzvf apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz -C ${CATALINA_DIR}
    sudo rm -rf apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz

    ###permission to tomcat user
    #need to change owner and group from mahesh to tomcat in the final one
    sudo chmod 755 -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
    sudo chown tomcat:tomcat -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
fi
#$"{CATALINA_DIR/apache-tomcat-$'{TOMCAT_VERSION_NUMBER}'}"
if [[ -f "/etc/systemd/system/tomcat.service" ]];
then
    sudo cp -f tomcat-service-file /etc/systemd/system/tomcat.service
    echo "found service file but copied new service file"
    sudo systemctl daemon-reload
    sudo systemctl enable tomcat
    sudo chmod 755 /etc/systemd/system/tomcat.service
    sudo chown tomcat:tomcat /etc/systemd/system/tomcat.service
    echo "changed user and permission for service file"
    sudo systemctl start tomcat
    echo "service found"
else
    echo "no service not found"
    ## description: Tomcat startup/ shutdown script
    # process name: tomcat

    sudo cp -f tomcat-service-file /etc/systemd/system/tomcat.service
    echo "copied service file"
    sudo systemctl daemon-reload
    sudo systemctl enable tomcat

    sudo chmod 755 /etc/systemd/system/tomcat.service
    sudo chown tomcat:tomcat /etc/systemd/system/tomcat.service
    echo "changed user and permission for service file"
    sudo systemctl start tomcat
fi

# In Tomcat, ROOT.war maps to the server root
if [[ "$DEPLOY_TO_ROOT" = 'true' ]];
then
    CONTEXT_PATH='ROOT'
fi

# Remove unpacked application artifacts
if [[ -f "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war" ]];
then
   sudo rm "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war"
fi
if [[ -d "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}" ]];
then
   sudo rm -rf "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}"
fi

# Copy the WAR file to the webapps directory
sudo cp ${WAR_STAGED_LOCATION} "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}/webapps/${CONTEXT_PATH}.war"
sudo systemctl restart tomcat
sudo systemctl status tomcat