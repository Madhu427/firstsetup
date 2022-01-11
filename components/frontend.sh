#!/bin/bash


#yum install nginx -y
## systemctl enable nginx
## systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.
#
## curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.
#
## cd /usr/share/nginx/html
## rm -rf *
## unzip /tmp/frontend.zip
## mv frontend-main/* .
## mv static/* .
## rm -rf frontend-master static README.md
## mv localhost.conf /etc/nginx/default.d/roboshop.conf
#Finally restart the service once to effect the changes.
#
## systemctl restart nginx

USER_ID=$(id -u) {
  if [ ${USER_ID} -ne 0 ]; then
    echo -e "\e[1;31mYou Should be the  root user to run the Script\e[0m"
    exit
  fi
}

yum install nginx -y