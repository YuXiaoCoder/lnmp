#!/bin/bash

Only_Install_Nginx()
{
    Init_Install
    source ${cur_dir}/include/nginx.sh
    Install_Nginx
}
Only_Install_Apache(){
    Init_Install
}
Only_Install_Database(){
    Init_Install
}

Only_Install_PHP(){
    Init_Install
}

LNMP_Stack(){
    Init_Install
}

Init_Install(){
    Press_Install
    Get_Dist_Version
    Print_Sys_Info
    Check_Hosts
    Set_Timezone
    Disable_Selinux

    if [ "${DISTRO}" = "CentOS" ]; then
        CentOS_Modify_Source
    elif [ "${DISTRO}" = "Ubuntu" ]; then
        Ubuntu_Modify_Source
    fi

    if [ "$PM" = "yum" ]; then
        CentOS_InstallNTP
        CentOS_Dependent
    elif [ "$PM" = "apt" ]; then
        Deb_InstallNTP
        Xen_Hwcap_Setting
        Deb_Dependent
    fi
}