#This service is written in NodeJS, Hence need to install NodeJS in the system.
#
## yum install nodejs make gcc-c++ -y
#Let's now set up the catalogue application.
#
#As part of operating system standards, we run all the applications and databases as a normal user but not with root user.
#
#So to run the catalogue service we choose to run as a normal user and that user name should be more relevant to the project. Hence we will use roboshop as the username to run the service.
#
## useradd roboshop
#So let's switch to the roboshop user and run the following commands.
#
#$ curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
#$ cd /home/roboshop
#$ unzip /tmp/catalogue.zip
#$ mv catalogue-main catalogue
#$ cd /home/roboshop/catalogue
#$ npm install
#NOTE: We need to update the IP address of MONGODB Server in systemd.service file
#Now, lets set up the service with systemctl.
#
## mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
## systemctl daemon-reload
## systemctl start catalogue
## systemctl enable catalogue

source components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
STAT_CHECK $? "Node JS Install"

id roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
useradd roboshop &>>${LOG_FILE}
STAT_CHECK $? "Add Application user"

DOWNLOAD catalogue

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/*  /home/roboshop/catalogue &>>${LOG_FILE}
STAT_CHECK $? "Copy catalogue content"

cd /home/roboshop/catalogue && npm install &>>${LOG_FILE}
STAT_CHECK $? "npm installed"

mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
systemctl daemon-reload &>>${LOG_FILE} && systemctl start catalogue  &>>${LOG_FILE} && systemctl enable catalogue &>>${LOG_FILE}
STAT_CHECK $? "Catalogue service start"
