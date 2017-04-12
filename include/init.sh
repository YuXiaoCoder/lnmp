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
    echo -e "${CQUESTION}Press any key to install or Press Ctrl+c to cancel.${CEND}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    source ${cur_dir}/include/version.sh
    echo ${Nginx_Ver}
    clear
}

Install_LSB()
{
    echo -e "${CMSG}[+] Installing lsb...${CEND}"
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
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Print System infomation.${CEND}"
    eval echo "${CMSG}${DISTRO}-\${${DISTRO}_Version}_$(uname -m)${CEND}"
    MemTotal=$(free -m | grep Mem | awk '{print  $2}')
    echo -e "${CMSG}Memory is: ${MemTotal} MB.${CEND}"
    df -h
}

Check_Hosts()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Check System's Hosts and DNS.${CEND}"
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo -e "${CMSG}Hosts is ok.${CEND}"
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    ping_result=`ping -c1 baidu.com 2>&1`
    if echo "${ping_result}" | grep -q "unknown host"; then
        echo -e "${CRED}DNS is fail.${CEND}"
        echo -e "Writing nameserver to /etc/resolv.conf...${CEND}"
        echo -e "nameserver 223.5.5.5\nnameserver 8.8.8.8" > /etc/resolv.conf
    else
        echo -e "${CMSG}DNS is ok.${CEND}"
    fi
}

Set_Timezone()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Setting timezone...${CEND}"
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

Disable_Selinux()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Disabled SELINUX...${CEND}"
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

CentOS_Modify_Source()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Set up and update the software source...${CEND}"
    \cp -f ${cur_dir}/conf/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s/\$releasever/${CentOS_Version}/g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${CentOS_Version}/g" /etc/yum.repos.d/CentOS-Base.repo
    yum clean all
    yum makecache
    yum update -y
}

Ubuntu_Modify_Source()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}Set up and update the software source...${CEND}"
    CodeName=""
    if grep -Eqi "14.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.04'; then
        CodeName='trusty'
    elif grep -Eqi "16.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.04'; then
        CodeName='xenial'
    elif grep -Eqi "16.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.10'; then
        CodeName='yakkety'
    else
        echo -e "${CRED}[*]: Script only supports Ubuntu(14.04, 16.04, 16.10).${CEND}"
        exit 1
    fi
    if [ ${CodeName} != "" ]; then
        \cp -f ${cur_dir}/conf/sources.list /etc/apt/sources.list
        sed -i "s/trusty/${CodeName}/g" /etc/apt/sources.list
        apt-get autoclean
        apt-get update -y
    fi
}

CentOS_InstallNTP()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}[+] Installing ntp...${CEND}"
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
}

Deb_InstallNTP()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}[+] Installing ntp...${CEND}"
    apt-get install -y ntpdate
    ntpdate -u pool.ntp.org
    date
}

Xen_Hwcap_Setting()
{
    if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
        sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
    fi
}

CentOS_Dependent()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}[+] Yum installing dependent packages...${CEND}"
    yum groupinstall -y "Development Tools"
    for packages in tree dos2unix make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz;
    do yum -y install ${packages}; done
}

Deb_Dependent()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}[+] Apt-get installing dependent packages...${CEND}"
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential gcc g++ make
    for packages in tree dos2unix debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev bison file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl3-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libjpeg-dev libpng12-dev libxml2-dev libcap-dev ca-certificates libc-client-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt1-dev xz-utils;
    do apt-get install -y ${packages} --force-yes; done
}

Tar_Cd()
{
    local FileName=$1
    local DirName=$2

    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar -zxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}