#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="var/log/shell-roboshop1"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.naren83.online

if [ $USERID -ne 0 ]; then
   echo -e "$R please run the script in root user $N" | tee -a $LOGS_FILE
   exit1
fi

mkdir $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 ....... $R FAILURE $N" |tee -a $LOGS_FILE
       exit1
    else
       echo -e "$2 ........ $G Sucess $N" | tee -a $LOGS_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo/etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Validate Rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? " Enable and Start rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? " Create user and give permissions"