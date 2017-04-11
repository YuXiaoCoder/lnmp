#!/bin/bash

# Cpu number of system
THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

# Get system digit
Get_OS_Bit()
{
    if [[ $(getconf WORD_BIT) = '32' && $(getconf LONG_BIT) = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}

# Get system name
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    else
        DISTRO='Unknow'
    fi
    Get_OS_Bit
}

Press_Install()
{
    Echo_Yellow "Press any key to install or Press Ctrl+c to cancel."
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    source ${cur_dir}/include/version.sh
}

Install_LSB()
{
    Echo_Green "[+] Installing lsb..."
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get install -y lsb-release
    fi
}

Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1])'`
    elif [ -s /usr/bin/python2 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1]'`
    fi
    if [ $? -ne 0 ]; then
        Install_LSB
        eval ${DISTRO}_Version=`lsb_release -rs`
    fi
}

Print_Sys_Info()
{
    Echo_Yellow "Print System infomation."
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    uname -a
    MemTotal=$(free -m | grep Mem | awk '{print  $2}')
    echo "Memory is: ${MemTotal} MB "
    df -h
    Echo_Carmine "+------------------------------------------------------------------------+"
}

Check_Hosts()
{
    Echo_Yellow "Check System's Hosts and DNS."
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        Echo_Green "Hosts is ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    ping_result=`ping -c1 baidu.com 2>&1`
#    echo "${ping_result}"
    if echo "${ping_result}" | grep -q "unknown host"; then
        Echo_Red "DNS is fail."
        echo "Writing nameserver to /etc/resolv.conf ..."
        echo -e "nameserver 223.5.5.5\nnameserver 8.8.8.8" > /etc/resolv.conf
    else
        Echo_Green "DNS is ok."
    fi
    Echo_Carmine "+------------------------------------------------------------------------+"
}

CentOS_Modify_Source()
{
    \cp -f ${cur_dir}/conf/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s/\$releasever/${CentOS_Version}/g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${CentOS_Version}/g" /etc/yum.repos.d/CentOS-Base.repo
    yum clean all
    yum makecache
    Echo_Carmine "+------------------------------------------------------------------------+"
}

Ubuntu_Modify_Source()
{
    CodeName=""
    if grep -Eqi "14.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.04'; then
        CodeName='trusty'
    elif grep -Eqi "16.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.04'; then
        CodeName='xenial'
    elif grep -Eqi "16.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.10'; then
        CodeName='yakkety'
    else
        Echo_Red "[*]: Script only supports Ubuntu(14.04, 16.04, 16.10)"
        exit 1
    fi
    if [ ${CodeName} != "" ]; then
        \cp -f ${cur_dir}/conf/sources.list /etc/apt/sources.list
        sed -i "s/trusty/${CodeName}/g" /etc/apt/sources.list
        apt-get autoclean
        apt-get update -y
    fi
    Echo_Carmine "+------------------------------------------------------------------------+"
}

Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    Echo_Carmine "+------------------------------------------------------------------------+"
}
