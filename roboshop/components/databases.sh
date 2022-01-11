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

cd /tmp/mongodb-main &>>${LOG_FILE}
STAT_CHECK $? "Extracting Mongodb"

mongo < catalogue.js &>>${LOG_FILE} && mongo < users.js &>>${LOG_FILE}
STAT_CHECK $? "Load schema"



## curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo
## yum install redis -y
#Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf
#
#Start Redis Database
#
## systemctl enable redis
## systemctl start redis

echo -e "\e[1;33m----------------> REDIS SETUP<--------------\e[0m"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
STAT_CHECK $? "Redis Repo Download "

yum install redis -y &>>${LOG_FILE}
STAT_CHECK $? "Redis Install"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/redis.conf &>>${LOG_FILE}
STAT_CHECK $? "Updated redis"

systemctl enable redis &>>${LOG_FILE} && systemctl start redis &>>${LOG_FILE}
STAT_CHECK $? "Start Redis"


#Erlang is a dependency which is needed for RabbitMQ.
## yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y
#Setup YUM repositories for RabbitMQ.
## curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
#Install RabbitMQ
## yum install rabbitmq-server -y
#Start RabbitMQ
## systemctl enable rabbitmq-server
## systemctl start rabbitmq-server
#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence we need to create one user for the application.
#
#Create application user
## rabbitmqctl add_user roboshop roboshop123
## rabbitmqctl set_user_tags roboshop administrator
## rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

echo -e "\e[1;33m----------------> RABBITMQ SETUP<--------------\e[0m"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG_FILE}
STAT_CHECK $? "Download RabbitMQ Repo"

yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG_FILE}
STAT_CHECK $? "Erlang & Rabbit MQ installed"


#yum install rabbitmq-server -y &>>{LOG_FILE}
#STAT_CHECK $? "Rabbit MQ installed"

systemctl enable rabbitmq-server &>>${LOG_FILE} && systemctl start rabbitmq-server &>>${LOG_FILE}
STAT_CHECK $? "Start Rabbit MQ"

rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
STAT_CHECK $? "App user setup"
fi

rabbitmqctl set_user_tags roboshop administrator &>>${LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG_FILE}
STAT_CHECK $? "Configure App user Permissions"



#Setup MySQL Repo
## curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
#
#Install MySQL
## yum install mysql-community-server -y
#
#Start MySQL.
## systemctl enable mysqld
## systemctl start mysqld
#
#Now a default root password will be generated and given in the log file.
## grep temp /var/log/mysqld.log
#
#Next, We need to change the default root password in order to start using the database service.
## mysql_secure_installation
#
#You can check the new password working or not using the following command.
#
## mysql -u root -p
#
#Run the following SQL commands to remove the password policy.
#> uninstall plugin validate_password;
#Setup Needed for Application.
#As per the architecture diagram, MySQL is needed by
#
#Shipping Service
#So we need to load that schema into the database, So those applications will detect them and run accordingly.
#
#To download schema, Use the following command
#
## curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
#Load the schema for Services.
#
## cd /tmp
## unzip mysql.zip
## cd mysql-main
## mysql -u root -pRoboShop@1 <shipping.sql


echo -e "\e[1;33m----------------> MYSQL SETUP<--------------\e[0m"

curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
STAT_CHECK $? "MY SQL Repo Install"

yum install mysql-community-server -y &>>${LOG_FILE}
STAT_CHECK $? "Install My SQL"

systemctl enable mysqld &>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
STAT_CHECK $? "Start My SQL"

DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

#echo 'show databases;' | mysql -uroot -pRoboshop@1  &>>${LOG_FILE}
#if [ $? -ne 0 ]; then
#echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Roboshop@1';" >/tmp/pass.sql
mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/pass.sql
#fi
STAT_CHECK $? "setup new root password"

echo 'show plugins;' | mysql -uroot -pRoboshop@1 2>>${LOG_FILE} | grep validate_password &>>${LOG_FILE}

if [ $? -ne 0 ]; then
  echo "uninstall plugin validate_password" | mysql -uroot -pRoboshop@1 &>>${LOG_FILE}
fi
  STAT_CHECK $? "Uninstall password plugin"

DOWNLOAD mysql

cd /tmp/mysql-main
mysql -u root -p Roboshop@1 <shipping.sql &>>${LOG_FILE}
STAT_CHECK $? "shipping service"


