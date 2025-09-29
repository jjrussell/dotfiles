#!/bin/bash

INSTANCE=""
INSTANCE_NAME=""

while getopts "n:i:a:t:f:" opt ; do
    case $opt in
	n ) echo "Setting name to $OPTARG" ; INSTANCE_NAME=$OPTARG ;;
	a ) INSTANCE=$OPTARG ;; # which AWS instance?
	i ) SSH_KEY=$OPTARG ;; 
	l ) LOCAL_FILE=$OPTARG ;; # for scp
	r ) REMOTE_FILE=$OPTARG ;; 
	? ) echo "huh? Usage $(basename $0) <ssh|create|term> [-n instance name]" ; exit 1 ;;
	
    esac
done
shift $(($OPTIND - 1))


# default to ssh if no args provided
COMMAND="${1-ssh}"
shift



AMI="ami-a9ce7bc0"
INSTANCE_TYPE="m1.xlarge"

#holds the last instance launched so subsequent commands can use it
AWS_LAST_LAUNCHED="/tmp/aws-last-instance-launched"

if [ -z "$INSTANCE" ] && [ -r  $AWS_LAST_LAUNCHED ] ; then
    INSTANCE=$(cat $AWS_LAST_LAUNCHED)
fi

if ( [ ! "$COMMAND" = "find" ] && [ ! "$COMMAND" = "grep" ] && [ ! "$COMMAND" = "name" ] ) && [ -z "$INSTANCE" ] ; then
    echo "I don't know what instance you mean."
    exit 1
fi

if [ -n "$SSH_KEY" ] ; then
    $SSH_KEY="-i $SSH_KEY"
fi

if [ "$COMMAND" = "term" ] ; then
    echo "Terminating instance $INSTANCE"
    ec2-terminate-instances $INSTANCE
elif [ "$COMMAND" = "create" ] ; then
    OUTPUT=$(ec2-run-instances $AMI --user-data-file ~/aws-bootstrap.sh --group jjrussell-test --key jjrussell-test -m  --instance-count 1 --instance-type $INSTANCE_TYPE)
    echo $OUTPUT
    LAUNCHED_INSTANCE=$(echo $OUTPUT | grep INSTANCE | awk '{print $6;}')
    echo "Launched instance is $LAUNCHED_INSTANCE. Stored in $AWS_LAST_LAUNCHED for subsequent commands"
    echo $LAUNCHED_INSTANCE > $AWS_LAST_LAUNCHED
    
    if [ -n "$INSTANCE_NAME" ] ; then
	echo "Setting instance name to $INSTANCE_NAME"
	ec2-create-tags $LAUNCHED_INSTANCE --tag Name="$INSTANCE_NAME"
    else
	echo "No name set for instance"
    fi

elif [ "$COMMAND" = "ssh" ] ; then
    echo "sshing into instance $INSTANCE"
    ssh $SSH_KEY $* ubuntu@$(ec2-describe-instances $INSTANCE | grep INSTANCE | awk '{print $14;}')    
elif [ "$COMMAND" = "scp" ] ; then
    if [ -n "$LOCAL_FILE" ] && [ -z "$REMOTE_FILE" ] ; then
	# drop local file in remote home dir
	REMOTE_FILE="" 
    elif [ -n "$REMOTE_FILE" ] && [ -z "$LOCAL_FILE" ] ; then
	# copy remote file here
	LOCAL_FILE="."
    elif [ -n "$REMOTE_FILE" ] && [ -n "$LOCAL_FILE" ] ; then
	# cool, just put remote file where we asked
	true
    else
	"Must specify local file/destination and/or remote file/destination using -l and -r"
	exit 3
    fi
	
    echo "scping file from instance $INSTANCE"
    scp $SSH_KEY ubuntu@$(ec2-describe-instances $INSTANCE | grep INSTANCE | awk '{print $14;}'):"$*" .
elif [ "$COMMAND" = "find" ] ; then
    RESULT=$(ec2-describe-instances $*)
    if [ $(echo $RESULT | egrep INSTANCE | wc -l) = "1" ] ; then
	# if there's only one result put its hostname in the clipboard (mac only)
	echo $RESULT | awk '{print $8;}' | tr -d "\n" | pbcopy	
    fi
    echo $RESULT
elif [ "$COMMAND" = "name" ] ; then
    aws find -F "tag:Name=$@"
elif [ "$COMMAND" = "grep" ] ; then
    ec2din | grep --after 1 -i reservation | grep --color -i "$@"
else
    echo "Unknown command: $COMMAND"
fi
