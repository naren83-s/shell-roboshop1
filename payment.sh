#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/hell-roboshop1"
LOGS_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.naren83.online


if [ $USERID -ne 0 ]; then
   echo -e "$R Please run the script in root user $N" | tee -a $LOGS_FILE
   exit1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 ......... $R FAILURE $N" | tee -a $LOGS_FILE
       exit1
    else
       echo -e "$2 ......... $G SUCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing phython"

id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
        VALIDATE $? " Creating system user"
    else
       echo -e "Roboshop user already exit ... $Y SKIPPING $N" &>> $LOGS_FILE
    fi

mkdir /app 
VALIDATE $? "Creating new app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOGS_FILE
Validate $? "Downloading payment code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? " Removing existing code"

unzip /tmp/payment.zip &>> $LOGS_FILE
VALIDATE $? "Uzip payment code"

cd /app 
pip3 install -r requirements.txt  &>> $LOGS_FILE
VALIDATE $? "installing depancies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Creating systemctl service"

systemctl daemon-reload
systemctl enable payment &>> $LOGS_FILE
systemctl start payment
VALIDATE $? "Enabled and started payment"

  