#!/bin/bash

# java -jar /mytool/agent.jar -url http://192.168.1.192:8888/ -secret 9551cc357a1d8668c3cbf5899ce4f80659fa211aabff33df95b452b365bd6b87 -name "linux192-xsw" -workDir "/home/xushuwei/g/jenkins-slave"


java -jar /mytool/agent.jar -url $JENKINS_URL -secret $JENKINS_SECRET -name $JENKINS_NAME -workDir $JENKINS_WORKDIR

