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

Assumptions and improvements:
  Assumptions:
    1. 
  Improvements:
    1.	Adding Jfrog artifactory server to save build artifacts e.g. Jar
    2.	Removing Jenkinsdata folder from the git and place in shared location on server
    3.	For deployment, I am using Jenkins 

