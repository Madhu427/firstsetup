
USER_ID=$(id -u)
  if [ ${USER_ID} -ne 0 ]; then
    echo -e "\e[1;31mYou Should be the  root user to run the Script\e[0m"
    exit
  fi


export COMPONENT=$1
if [ -z "${COMPONENT}" ]; then
  echo -e "\e[1;31mComponent input is missing\e[0m"
  exit
fi

if [ ! -e components/${COMPONENT}.sh ]; then
  echo -e "\e[1;31mGiven Component doesn't exists\e[0m"
  exit
fi

bash components/${COMPONENT}.sh