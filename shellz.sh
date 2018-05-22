#!/bin/bash
# script to start and stop an ec2 running shellinabox
# ./shellz.sh <start/stop>
        case "$1" in
                "start")
                        if [ -f /home/kfc/ami.out ]; then
                                echo "ami.out exists, is there an ec2 already running?"
                                exit 1
                        else
                                aws ec2 run-instances --image-id ami-xxxxx --count 1 --instance-type t2.nano --key-name xxxxxx-key --security-group-ids sg-xxxxx --subnet-id subnet-xxxxx --associate-public-ip-address > ami.out
                                instanceid=$(cat ami.out | grep InstanceId | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
                                sleep 15s
                                shellzip=$(aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[*].Instances[*].PublicIpAddress" --output=text)
                                /opt/google/chrome/chrome --ignore-certificate-errors https://$shellzip
                        fi
                        ;;
                "stop")
                        if [ ! -f ami.out ]; then
                                echo "ami.out does not exist, are you sure there is an ec2 running?"
                                exit 1
                        else
                                instanceid=$(cat ami.out | grep InstanceId | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
                                aws ec2 terminate-instances --instance-ids $instanceid
                                rm -rf ami.out
                        fi
                        ;;
                *)
                        echo "Usage: ./shellz.sh <start/stop>"
                        exit 1
                        ;;
        esac
