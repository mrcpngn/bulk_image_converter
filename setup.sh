#!/bin/bash
OS_TYPE=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

if [[ $OS_TYPE = '"Ubuntu"' ]]
then
    echo "INFO: Installing dependencies"
    sudo apt install inotify-tools -y
    sudo apt install imagemagick -y
    echo "INFO: Creating folders"
    mkdir in out
    mkdir $(echo $PWD) -p config/watermark config/logs
    mv settings.ini image_converter.sh $(echo $PWD)/config

elif [[ $OS_TYPE = '"RedHat"' ]]
then

    echo "INFO: Installing dependencies"
    sudo yum install inotify-tools -y
    sudo yum install imagemagick -y
    echo "INFO: Creating folders"
    mkdir in out
    mkdir $(echo $PWD) -p config/watermark config/logs
    mv settings.ini image_converter.sh $(echo $PWD)/config

fi
