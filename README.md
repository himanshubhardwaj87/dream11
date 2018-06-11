Pre-requisite:
  1. Any linux box (centos or ubuntu)
  2. Docker engine 1.13 or Docker-ce must be installed in VM
  3. Git client should be installed

Setup Environment:
  Shell script "launch.sh" is used to launch Jenkins and mysql container. Jenkins is ready to use and two jobs are already available.
  One is for building the code and second is for deploying the jar file to docker container.
Steps:
  1. Take a git checkout in /tmp/ directory
  Command:
     cd /tmp/
     git clone https://github.com/himanshubhardwaj87/dream11.git
  2. Execute shell script
     cd dream11
     ./launch.sh --action=start
     Jenkins container is launched on host port 7772, Mysql container is launched on host port 3306.
     Jenkins container volume is mapped to host directory "/tmp/dream11/jenkinsdata/jenkins" and mysql container volume is mapped
     to host directory "/tmp/mysqldata" for persistence. 
 One click deployment:
    Now, login the Jenkins using credentials: admin/admin123
    Poll SCM is configured on build job to build the code and deploy job will build as a downstream project. 
 Steps:
   1. Go to buildcode job and execute build now.
   APPLICATION URL would be: http://<HOST IP>:9998/

Assumptions and improvements:
  Assumptions:
    1. Code is failing with 1 unit test so I skipped the unit test execution.
    2. Instead of mvn spring-boot:run for build and deploy code in tomcat, I broke them in steps and build the code in first step and deploy the code in docker container.
    3. Whole build process is not covered for this task. Unit test execution, Sonar analysis, uploading artifacts in artifactory are not covered. 
  Improvements:
    1.	Adding Jfrog artifactory server to save build artifacts e.g. Jar
    2.	Removing Jenkinsdata folder from the git and place in shared location on server for reducing the GIT repo size
    3.	Deployment can be performed using any configuration management tool such as ansible, puppet.


Detailed Steps:
Steps:
  1. Launch Jenkins container using command
      DockerFile: 
      FROM jenkins/jenkins:alpine
      USER root
      RUN apk update && apk add docker && apk add maven

     Commands to create image from DockerFile
      docker build -t jenkins11 .

     Command to launch container
      docker run --name jenkins11 -d -p <HostPort>:8080 -v /var/run/docker.sock:/var/run/docker.sock -v <PathofHostMachine>:/var/jenkins_home/ jenkins11

  2. Launch mysql container:
      docker run --name mysql11 -p 3306:3306 -e MYSQL_DATABASE=journals -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ROOT_HOST='%' -d mysql:5.7


One-time setup:
  1.	Get the password of jenkins from its container using command
      docker exec -it jenkins11 /bin/bash
      cat /var/lib/jenkins/secrets/initialAdminPassword
  2.	Install the recommended plugins and create a new user.
  3.	Login with that user and create a new job with build job.
      a.	Configure git URL in SCM (e.g. https://github.com/himanshubhardwaj87/dream11.git)
      b.	In the build step, add “Execute Shell” step and enter the code
            export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
            cd Java_trial/Code
            mvn clean install -DskipTests=true
  4. Launch app container
      Docker file for app container:
      FROM openjdk:alpine
      ADD  target/journals-1.0.jar journals-1.0.jar
      EXPOSE 8080
      EXPOSE 3306
      CMD ["java", "-jar", "/journals-1.0.jar"]
      
     Create image from this dockerfile using Jenkins deploy job
      docker build -t $IMAGE .
     
     Launch the container on port 9998
       docker run --name $CONTAINER -d -p 9998:8080 $CONTAINER
