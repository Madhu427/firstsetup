#!/bin/bash


#yum install nginx -y
## systemctl enable nginx
## systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.
#
## curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.
#


source components/common.sh

yum install nginx -y &>>${LOG_FILE}
STAT_CHECK $? "Nginx installation"


DOWNLOAD frontend

rm -rf /usr/share/nginx/html/*
STAT_CHECK $? "Remove old html files"



cd /tmp/frontend-main/static && cp -r * /usr/share/nginx/html
STAT_CHECK $? "copy frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT_CHECK $? "copy Nginx"

sed -i -e "/catalogue/ s/localhost/catalogue.firstsetup.public/" \
      -e "/user/ s/localhost/user.firstsetup.public/" \
      -e "/cart/ s/localhost/cart.firstsetup.public/" \
      -e "/shipping/ s/localhost/shipping.firstsetup.public/" \
      -e "/payment/ s/localhost/payment.firstsetup.public/" /etc/nginx/default.d/roboshop.conf &>>${LOG_FILE}
 STAT_CHECK $? "Update roboshop.conf"


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