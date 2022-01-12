#!/bin/bash

source components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
STAT_CHECK $? "Node JS Install"

id roboshop &>>${LOG_FILE}
 if [ $? -ne 0 ]; then
 useradd roboshop &>>${LOG_FILE}
 STAT_CHECK $? "Add Application user"
 fi

DOWNLOAD catalogue

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/*  /home/roboshop/catalogue &>>${LOG_FILE}
STAT_CHECK $? "Copy catalogue content"

cd /home/roboshop/catalogue && npm install --unsafe-perm &>>${LOG_FILE}
STAT_CHECK $? "npm installed"



chown roboshop:roboshop -R /home/roboshop

sed -i "s/MONGO_DNSNAME/mongodb.firstsetup.public/" /home/roboshop/catalogue/systemd.service &>>${LOG_FILE} && mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}

STAT_CHECK $? "Mongodb ip address updated"

systemctl daemon-reload &>>${LOG_FILE} && systemctl start catalogue  &>>${LOG_FILE} && systemctl enable catalogue &>>${LOG_FILE}
STAT_CHECK $? "Catalogue service start"