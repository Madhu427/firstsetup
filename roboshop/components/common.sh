LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

MAX_LENGTH=$(cat components/*.sh | grep -v -w cat | grep STAT_CHECK | awk -F '"' '{print $2}'| awk '{print length}'|sort | tail -1)

if [ $MAX_LENGTH -lt 26 ]; then
       MAX_LENGTH =26
fi

STAT_CHECK() {
  SPACE=""
    LENGTH=$(echo $2 |awk '{ print length }' )
    LEFT=$((${MAX_LENGTH}-${LENGTH}))
    while [ $LEFT -gt 0 ]; do
      SPACE=$(echo -n "${SPACE} ")
      LEFT=$((${LEFT}-1))
    done

  if [ $1 -ne 0 ]; then
    echo -e "\e[1m${2}${SPACE} - \e[1;31mFAILED\e[0m"
    exit 1
  else
    echo -e "\e[1m${2}${SPACE} - \e[1;32mSuccess\e[0m"
  fi
}

set-hostname -skip-apply ${COMPONENT}

DOWNLOAD() {
 curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
 STAT_CHECK $? "Download ${1} Schema"

 cd /tmp && unzip -o /tmp/${1}.zip &>>${LOG_FILE}
 STAT_CHECK $? "Unzipped ${1} content"
}


NODEJS() {

  yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
  STAT_CHECK $? "Node JS Install"

  id roboshop &>>${LOG_FILE}
   if [ $? -ne 0 ]; then
   useradd roboshop &>>${LOG_FILE}
   STAT_CHECK $? "Add Application user"
   fi

  component=${1}
  DOWNLOAD ${component}

  rm -rf /home/roboshop/${component} && mkdir -p /home/roboshop/${component} && cp -r /tmp/${component}-main/*  /home/roboshop/${component} &>>${LOG_FILE}
  STAT_CHECK $? "Copy ${component} content"

  cd /home/roboshop/${component} && npm install --unsafe-perm &>>${LOG_FILE}
  STAT_CHECK $? "npm installed"



  chown roboshop:roboshop -R /home/roboshop

  sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.firstsetup.public/" \
  -e "s/MONGO_DNSNAME/mongodb.firstsetup.public/" \
  -e "s/REDIS_ENDPOINT/redis.firstsetup.public/" \
   -e "s/MONGO_ENDPOINT/mongodb.firstsetup.public/" \
/home/roboshop/${component}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${component}/systemd.service /etc/systemd/system/${component}.service &>>${LOG_FILE}

  STAT_CHECK $? "Mongodb ip address updated"

  systemctl daemon-reload &>>${LOG_FILE} && systemctl start ${component}  &>>${LOG_FILE} && systemctl enable ${component} &>>${LOG_FILE}
  STAT_CHECK $? "${component} service start"
}
