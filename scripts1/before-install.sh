#!/bin/bash


set -e

CATALINA_DIR="/home/ec2-user" #my tomcat catalina directory
TOMCAT_VERSION_NUMBER=9.0.78
#PROJECT_HOME="/home/ec2-user/Desktop/projects/tomcat-codedeploy-test/validator-test/conf"

echo "Tomcat group and user are going to be created."
TOMCAT_GROUP="tomcat"
TOMCAT_USER="tomcat"

# Create the Tomcat group
if ! getent group "${TOMCAT_GROUP}" > /dev/null; then
    groupadd "${TOMCAT_GROUP}"
fi

# Create the Tomcat user without login shell access
if ! getent passwd "${TOMCAT_USER}" > /dev/null; then
  useradd -M -g "${TOMCAT_GROUP}" -s /usr/sbin/nologin "${TOMCAT_USER}"
fi

# Print a message indicating the successful creation of the group and user
echo "group and user got created successfully"

#make PROJECT_HOME directory
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
#chmod 755 -R ${PROJECT_HOME}
#chown tomcat:tomcat -R ${PROJECT_HOME}
#echo "made the owner tomcat and changed the mode to 755"


##check if tomcat is already installed or not
if [[ -d "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}" ]];
then
    echo "Tomcat is installed at ${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
    echo "no need to download"
else
    echo "Tomcat is not installed at ${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"

    ###download tomcat
    wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION_NUMBER}/bin/apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz

    ####extract tomcat
    tar -xzvf apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz -C ${CATALINA_DIR}
    rm -rf apache-tomcat-${TOMCAT_VERSION_NUMBER}.tar.gz

    ###permission to tomcat user
    #need to change owner and group from mahesh to tomcat in the final one
    chmod 755 -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
    chown tomcat:tomcat -R "${CATALINA_DIR}/apache-tomcat-${TOMCAT_VERSION_NUMBER}"
fi

if [[ -f "/etc/systemd/system/tomcat.service" ]];
then
#    cp -f tomcat-service-file /etc/systemd/system/tomcat.service
    echo "found service file but copied new service file"
    chmod 755 /etc/systemd/system/tomcat.service
    chown tomcat:tomcat /etc/systemd/system/tomcat.service
    echo "changed user and permission for service file"
    systemctl daemon-reload
    systemctl enable tomcat
    echo "service found"
else
    echo "no service not found"
    ## description: Tomcat startup/ shutdown script
    # process name: tomcat

    cp -f ../tomcat-service-file /etc/systemd/system/tomcat.service
    echo "copied service file"

    chmod 755 /etc/systemd/system/tomcat.service
    chown tomcat:tomcat /etc/systemd/system/tomcat.service
    echo "changed user and permission for service file"
    systemctl daemon-reload
    systemctl enable tomcat

fi




