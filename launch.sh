#!/bin/sh
#########################################################
# This script contains is used to configure             #
# pre-requisites                                        #
#                                                       #
# Version: 1.0.0                                        #
# Creation Date: 06112018                               #
#########################################################

export TERM=xterm

#-- DisplaY=1 will Hide Output on screen
DisplaY=0

#-- Variables for the script
MinparaM=0
MaxparaM=1
DisplaY=0

## GIT Params
GIT_CHECKOUT_DIR="/tmp/"
GIT_REPO_NAME="dream11"

##Jenkins Vars
JenkinsHomeWorkspace="${GIT_CHECKOUT_DIR}dream11/jenkinsdata/"
JenkinsHome="${GIT_CHECKOUT_DIR}jenkinsdata"
JenkinsUser="admin"
JenkinsApiToken="de87bd277f1d4ec9b7f15bdfd3b9b472"

JenkinsStatusQuery="/lastBuild/api/xml"

## Docker Params
DOCKER_CMD=`which docker`
JENKINS_IMAGE="jenkins11"
JENKINS_CONTAINER="jenkins11"

## mysql Params
MYSQL_IMAGE="mysql/mysql-server"
MSYQL_TAG="5.7"
MYSQL_CONTAINER="mysql11"
MYSQL_DATABASE="journals"
MYSQL_ROOT_PASSWORD="root"
MYSQL_ROOT_HOST="%"
MYSQL_DATA="${GIT_CHECKOUT_DIR}mysqldata"

## Function to setup jenkins directory
setup_jenkins()
{
        ## Check Jenkins Dir and Create If needed
        if [[ -d ${JenkinsHomeWorkspace} ]]
        then
                export  JenkinsHomeDir="${JenkinsHome}"
                if [[ -d "${JenkinsHomeDir}/jenkins_home" ]]
                then
                        export JenkinsHomeFinal="${JenkinsHomeDir}/jenkins_home"
                else
                        `mkdir -p  ${JenkinsHomeDir}`  2>>/dev/null
                        cp -r ${JenkinsHomeWorkspace} ${JenkinsHomeDir}
                        output=$?
                        export JenkinsHomeFinal="${JenkinsHomeDir}/jenkins_home"
                fi
        else
                echo "Missing Base Workspace for Jenkins"
                exit 0
        fi
		# launch jenkins image
		cd ${JenkinsHomeWorkspace}
                export DockerImage=`${DOCKER_CMD} build -t ${JENKINS_IMAGE} `
        output=$?
}

check_launch_jenkins()
{
        id=`docker ps --filter "name=${JENKINS_CONTAINER}" | grep -v CREATED | awk '{print $1}' `
        if [[ ! -z $id || $id != "" ]]
        then
                echo "Jenkins Container Already Running with ID - ${id}" 0
                export JenkinsContainerID=${id}
        else
                export JenkinsContainerID=`${DOCKER_CMD} run --name ${JENKINS_CONTAINER} -d -p 7772:8080 -v /var/run/docker.sock:/var/run/docker.sock -v ${JenkinsHomeFinal}:${JenkinsHomeWorkspace} ${JENKINS_IMAGE} `
        output=$?
        fi

}

setup_mysql()
{
        ## Check mysql Dir and Create If needed
        if [[ -d "${MYSQL_DATA}" ]]
            then
                export mysql_dir="${MYSQL_DATA}"
            else
               `mkdir -p  ${MYSQL_DATA}`  2>>/dev/null
                export mysql_dir="${MYSQL_DATA}"
        fi
        return 0
}


check_launch_mysql()
{
        id=`docker ps --filter "name=${MYSQL_CONTAINER}" | grep -v CREATED | awk '{print $1}' `
        if [[ ! -z $id || $id != "" ]]
        then
                echo "Mysql Container Already Running with ID - ${id}" 0
                export MysqlContainerID=${id}
        else
                export MysqlContainerID=`${DOCKER_CMD} run --name ${MYSQL_CONTAINER} -d -p 3306:3306 -v ${MYSQL_DATA}:/var/lib/mysql -e MYSQL_DATABASE=${MYSQL_DATABASE} -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -e MYSQL_ROOT_HOST='${MYSQL_ROOT_HOST}' ${MYSQL_IMAGE}:${MSYQL_TAG} `
        output=$?
        fi

}

start_setup()
{
        setup_jenkins
        check_launch_jenkins
        setup_mysql
	check_launch_mysql
}

UsagE()
{
        echo
        echo "[ UsagE ] :: sh $0  --action=<start> "
        echo "---------------------------------------------------------"
        echo " | action(start) : Actual Action for the script to perform."
        exit 101
}
#######Initializing the script
if [[ $# -gt $MinparaM ]]
then
        NumberofparaM=$#
        if [ $NumberofparaM -gt $MaxparaM ]
        then
                echo "Maximum $MaxparaM parameters are allowed" 9
                UsagE
        fi
        for (( cmdArg=$MinparaM ; cmdArg<=$NumberofparaM ; cmdArg++ ))
        do
                        ParamnamE=`echo ${!cmdArg} | awk -F"--" '{printf $2"\n"}' | cut -d"=" -f1`
                        if [ ! -z $ParamnamE ]
                        then
                                case $ParamnamE in
                        "action")
                                export action=`echo ${!cmdArg} | grep "\-\-action="| cut -d"=" -f2`
                                echo "Setting Variable $ParamnamE=$action" 0 ;;
                        *)
                               echo "Unknown Parameter - $ParamnamE" 9
                               UsagE;;
                        esac

                        fi
        done
		if [[ ${action,,} == "start" ]]
        then
			start_setup
		fi
fi
