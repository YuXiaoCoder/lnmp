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
source ./include/colors.sh
source ./include/init.sh
source ./include/main.sh

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo -e "${CFAILURE}Error: You must be root to run this script!!!${CEND}"
    exit 1
fi

# Get current working directory
cur_dir=$(pwd)

clear
# Output prompt message
echo "+------------------------------------------------------------------------+"
echo -e "|${CMSG}                 LNMP for CentOS 6+ and Ubuntu 14+                      ${CEND}|"
echo "+------------------------------------------------------------------------+"
echo -e "|${CMSG}        A tool to auto-compile & install LNMP/LNMPA/LAMP on Linux       ${CEND}|"
echo "+------------------------------------------------------------------------+"
echo -e "|${CMSG}         For more information please visit https://xiaocoder.com        ${CEND}|"
echo "+------------------------------------------------------------------------+"

# ./include/functions.sh
Get_Dist_Name

if [ "${DISTRO}" = "Unknow" ]; then
    echo -e "${CFAILURE}Unable to get Linux distribution name or do NOT support the current distribution.${CEND}"
    exit 1
fi

echo "+------------------------------------------------------------------------+"
echo -e "${CQUESTION}Please select the service you want to install: ${CEND}"
echo -e "|----${CMSG}1.${CEND} Install only ${CMSG}Nginx${CEND} services;"
echo -e "|----${CMSG}2.${CEND} Install only ${CMSG}Apache${CEND} services;"
echo -e "|----${CMSG}3.${CEND} Install only ${CMSG}Database${CEND} services;"
echo -e "|----${CMSG}4.${CEND} Install only ${CMSG}PHP${CEND} services;"
echo -e "|----${CMSG}5.${CEND} Install ${CMSG}LNMP${CEND} stack;"

while :; do
    read -p "Please input a number(Default 1 press Enter): " Menu_index
    [ -z "${Menu_index}" ] && Menu_index=1
    if [[ ! ${Menu_index} =~ ^[1-5]$ ]]; then
        echo -e "${CWARNING}Input error! Please only input number 1,2,3,4,5${CEND};"
    else
        [ ${Menu_index} = '1' ] && Only_Install_Nginx && break
        [ ${Menu_index} = '2' ] && Only_Install_Apache && break
        [ ${Menu_index} = '3' ] && Only_Install_Database && break
        [ ${Menu_index} = '4' ] && Only_Install_Apache && break
        [ ${Menu_index} = '5' ] && Only_Install_PHP && break
    fi
done
echo "+------------------------------------------------------------------------+"
echo -e "|${CSUCCESS}           The task has been completed, the program has exited          ${CEND}|"
echo "+------------------------------------------------------------------------+"
