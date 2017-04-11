#!/bin/bash
# Author:  YuXiao <xiao.950901@gmail.com>
# BLOG:  https://www.xiaocoder.com
# GitHub: https://github.com/YuXiaoCoder
#
# Notes: LNAMP for CentOS 6+ and Ubuntu 14+

# Set environment variables
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Load configuration and script files
source ./options.conf
source ./include/functions.sh
source ./include/init.sh
source ./include/main.sh



# Check if user is root
if [ $(id -u) != "0" ]; then
    Echo_Red "Error: You must be root to run this script!!!"
    exit 1
fi

# Get current working directory
cur_dir=$(pwd)

clear
# Output prompt message
echo "+------------------------------------------------------------------------+"
echo -e "|\e[0;32m                 LNMP for CentOS 6+ and Ubuntu 14+                      \e[0m|"
echo "+------------------------------------------------------------------------+"
echo -e "|\e[0;32m        A tool to auto-compile & install LNMP/LNMPA/LAMP on Linux       \e[0m|"
echo "+------------------------------------------------------------------------+"
echo -e "|\e[0;32m         For more information please visit https://xiaocoder.com        \e[0m|"
echo "+------------------------------------------------------------------------+"

# ./include/functions.sh
Get_Dist_Name

if [ "${DISTRO}" = "Unknow" ]; then
    Echo_Red "Unable to get Linux distribution name or do NOT support the current distribution."
    exit 1
fi

Stack=$1
if [ "${Stack}" = "" ]; then
    Stack="lnmp"
fi

if [[ "${Stack}" = "lnmp" || "${Stack}" = "lnmpa" || "${Stack}" = "lamp" ]]; then
    if [ -f /bin/lnmp ]; then
        Echo_Red "You have installed LNMP!"
        echo -e "If you want to reinstall LNMP, please BACKUP your data.\nand run uninstall script: ./uninstall.sh before you install."
        exit 1
    fi
fi

Init_Install()
{
    Press_Install
    Print_APP_Ver
    Get_Dist_Version
    Print_Sys_Info
    Check_Hosts
    Set_Timezone

    if [ "${DISTRO}" = "CentOS" ]; then
        CentOS_Modify_Source
    elif [ "${DISTRO}" = "Ubuntu" ]; then
        Ubuntu_Modify_Source
    fi
}

Dispaly_Selection
Init_Install
