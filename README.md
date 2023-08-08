# Tomcat setup through codedeploy

This repository contains appspec.yml file for codedeploy agent where four life cycle events are defined.

- ApplicationStop : This contains appllication-stop.sh script which stops the running tomcat service.
- BeforeInstall : This contains before-install.sh script which sets up the tomcat user and group, install tomcat as per condition and copies the tomcat.service file for systemd.
- AfterInstall: This contains after-install.sh which removes ROOT and ROOT.war from webapps of catalina directory and copies war file to webapps as ROOT.war and deplyos it to tomcat server.
- ApplicationStart: This contains application-start.sh script which starts the tomcat service.

You can also find one complete setup in complete-tomcat.sh script file.

