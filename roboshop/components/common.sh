LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

MAX_LENGTH=${cat components/databases.sh | grep -v -w cat | grep STAT_CHECK | awk -F '"' '{print $2}'| awk '{print length}'|sort | tail -1
}

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