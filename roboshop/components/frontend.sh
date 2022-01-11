#!/bin/bash


#yum install nginx -y
## systemctl enable nginx
## systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.
#
## curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.
#


LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

STAT_CHECK() {

  if [ $1 -ne 0 ]; then
    echo -e "\e[1;31m${2} - FAILED\e[0m"
    exit 1
  else
    echo -e "\e[1;32m${2} - Success\e[0m"
  fi
}


yum install nginx -y &>>${LOG_FILE}
STAT_CHECK $? "Nginx installation"


curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG_FILE}
STAT_CHECK $? "Download Frontend"

rm -rf /usr/share/nginx/html/*
STAT_CHECK $? "Remove old html files"

cd /tmp && unzip -o /tmp/frontend.zip &>>${LOG_FILE}
STAT_CHECK $? "Extracting Frontend content"

cd /tmp/frontend-main/static && cp -r * /usr/share/nginx/html
STAT_CHECK $? "copy frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT_CHECK $? "update Nginx"

systemctl enable nginx &>>${LOG_FILE} && systemctl start nginx &>>${LOG_FILE}
STAT_CHECK $? "Restart Nginx"




## cd /usr/share/nginx/html
## rm -rf *  --> rm -rf /usr/share/nginx/html/*
## unzip /tmp/frontend.zip
## mv frontend-main/* .
## mv static/* ---> cd /tmp/frontend-main/static.
## rm -rf frontend-master static README.md
## mv localhost.conf /etc/nginx/default.d/roboshop.conf
#Finally restart the service once to effect the changes.
#
## systemctl restart nginx