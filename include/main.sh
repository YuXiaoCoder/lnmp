#!/bin/bash

DB_Info=('MySQL 5.7.17' 'MariaDB 10.1.22')
PHP_Info=('PHP 5.6.30' 'PHP 7.1.3')

Database_Selection()
{
# Which MySQL Version do you want to install?
    Echo_Carmine "+------------------------------------------------------------------------+"
    DB_Count=${#DB_Info[@]}
    DBSelect="1"
    Echo_Yellow "You have ${DB_Count} options for your DataBase install."
    for ((i=0; i<DB_Count; i++))
    {
        echo "$(($i+1)): Install ${DB_Info[i]}"
    }
    echo "0: DO NOT Install MySQL/MariaDB"
    Echo_Blue "Enter your choice $(seq ${DB_Count}) or 0. (Default select: 1)"
    read -p "Please enter: " DBSelect

    case "${DBSelect}" in
    1)
        Echo_Green "You will install ${DB_Info[0]}"
        ;;
    2)
        Echo_Green "You will install ${DB_Info[1]}"
        ;;
    0)
        Echo_Green "Do not install MySQL/MariaDB!"
        ;;
    *)
        Echo_Green "No input, You will install ${DB_Info[0]}"
        DBSelect="1"
    esac

    if [[ "${DBSelect}" != "0" ]] && [ $(free -m | grep Mem | awk '{print $2}') -le 1024 ]; then
        Echo_Red "Memory less than 1GB, can't install MySQL or MairaDB!"
        exit 1
    fi

    if [[ "${DBSelect}" = "1" ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
    elif [[ "${DBSelect}" = "2" ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
    fi

    if [[ "${DBSelect}" != "0" ]]; then
        # Set DataBase root password
        Echo_Carmine "+------------------------------------------------------------------------+"
        DB_Root_Password="root"
        Echo_Blue "Please setup root password of DataBase. (Default password: root)"
        read -p "Please enter: " DB_Root_Password
        if [ "${DB_Root_Password}" = "" ]; then
            DB_Root_Password="root"
        fi
        Echo_Green "DataBase root password: ${DB_Root_Password}"

        # Do you want to enable or disable the InnoDB Storage Engine?
        Echo_Carmine "+------------------------------------------------------------------------+"
        InstallInnodb="y"
        Echo_Blue "Do you want to enable or disable the InnoDB Storage Engine?"
        read -p "Default enable, Enter your choice [Y/n]: " InstallInnodb

        case "${InstallInnodb}" in
        [yY])
            Echo_Green "You will enable the InnoDB Storage Engine"
            InstallInnodb="y"
            ;;
        [nN])
            Echo_Green "You will disable the InnoDB Storage Engine!"
            InstallInnodb="n"
            ;;
        *)
            Echo_Green "No input, The InnoDB Storage Engine will enable."
            InstallInnodb="y"
        esac
    fi
}

PHP_Selection()
{
# Which PHP Version do you want to install?
    Echo_Carmine "+------------------------------------------------------------------------+"
    PHP_Count=${#PHP_Info[@]}
    PHPSelect="1"
    Echo_Yellow "You have ${PHP_Count} options for your PHP install."
    for ((i=0; i<PHP_Count; i++))
    {
        echo "$(($i+1)): Install ${PHP_Info[i]}"
    }
    echo "0: DO NOT Install PHP"
    Echo_Blue "Enter your choice $(seq ${PHP_Count}) or 0. (Default select: 1)"
    read -p "Please enter: " PHPSelect

    case "${PHPSelect}" in
    1)
        Echo_Green "You will install ${PHP_Info[0]}"
        ;;
    2)
        Echo_Green "You will install ${PHP_Info[1]}"
        ;;
    0)
        Echo_Green "Do not install PHP"
        ;;
    *)
        Echo_Green "No input, You will install ${PHP_Info[1]}"
        PHPSelect="1"
    esac
    Echo_Carmine "+------------------------------------------------------------------------+"
}

Dispaly_Selection()
{
    Database_Selection
    PHP_Selection
}

Print_APP_Ver()
{
    Echo_Carmine "+------------------------------------------------------------------------+"
    Echo_Green "You will install ${Stack} stack."
    Echo_Yellow "Print application version."
    if [ "${Stack}" != "lamp" ]; then
        echo ${Nginx_Ver}
    fi

    if [ "${Stack}" != "lnmp" ]; then
        echo "${Apache_Ver}"
    fi

    if [[ "${DBSelect}" = "1" ]]; then
        echo "${Mysql_Ver}"
        echo "Database Directory: ${MySQL_Data_Dir}"
    elif [[ "${DBSelect}" = "2" ]]; then
        echo "${Mariadb_Ver}"
        echo "Database Directory: ${MariaDB_Data_Dir}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi

    if [[ ${Php_Ver} != "" ]]; then
        echo "${Php_Ver}"
    fi

    echo "Enable InnoDB: ${InstallInnodb}"
    echo "Print options.conf infomation..."
    echo "Default Website Directory: ${Default_Website_Dir}"
    if [[ ${Nginx_Modules_Options} != "" ]];then
        echo "Nginx Additional Modules: ${Nginx_Modules_Options}"
    fi
    if [[ ${PHP_Modules_Options} != "" ]];then
        echo "PHP Additional Modules: ${PHP_Modules_Options}"
    fi
    Echo_Carmine "+------------------------------------------------------------------------+"
}