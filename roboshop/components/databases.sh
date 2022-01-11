## curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo
#Install Mongo & Start Service.
## yum install -y mongodb-org
## systemctl enable mongod
## systemctl start mongod
#Update Liste IP address from 127.0.0.1 to 0.0.0.0 in config file
#Config file: /etc/mongod.conf
#
#then restart the service
#
## systemctl restart mongod
#Every Database needs the schema to be loaded for the application to work.
#Download the schema and load it.
#
## curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"
#
## cd /tmp
## unzip mongodb.zip
## cd mongodb-main
## mongo < catalogue.js
## mongo < users.js

source components/common.sh
echo -e "\e[1;33m----------------> MONGODB SETUP<--------------\e[0m"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
STAT_CHECK $? "Mongodb Repo file download"

yum install -y mongodb-org  &>>${LOG_FILE}
STAT_CHECK $? "Mongdb Installation"

systemctl enable mongod &>>${LOG_FILE} && systemctl start mongod &>>${LOG_FILE}
STAT_CHECK $? "Start mongodb"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>>${LOG_FILE}
STAT_CHECK $? "Update mongodb"

DOWNLOAD mongodb

cd mongodb-main &>>${LOG_FILE}
STAT_CHECK $? "Extracting Mongodb"

mongo < catalogue.js &>>${LOG_FILE} && mongo < users.js &>>${LOG_FILE}
STAT_CHECK $? "mongodb service"



