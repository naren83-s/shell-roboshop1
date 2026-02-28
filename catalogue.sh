#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop1"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Desable nodejs default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable nodejs 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then

   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "creating system user"
else
   echo -e "Roboshop user already existing ..... $Y SKIPPING $N "
fi

mkdir -p /app 
VALIDATE $? " Creating Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Download catalogue code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -r /app/*
VALIDATE $? "Removing exist code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Unzip catalogue code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created system service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"