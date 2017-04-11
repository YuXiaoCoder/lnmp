#!/bin/bash

Apache_Ver='httpd-2.4.25'
Nginx_Ver='nginx-1.10.3'
Openssl_Ver='openssl-1.0.2k'

if [ "${DBSelect}" = "1" ]; then
    Mysql_Ver='mysql-5.7.17'
elif [ "${DBSelect}" = "2" ]; then
    Mariadb_Ver='mariadb-10.1.22'
fi

if [ "${PHPSelect}" = "1" ]; then
    Php_Ver='php-5.6.30'
elif [ "${PHPSelect}" = "2" ]; then
    Php_Ver='php-7.1.3'
fi

Autoconf_Ver='autoconf-2.69'
Libiconv_Ver='libiconv-1.15'
LibMcrypt_Ver='libmcrypt-2.5.8'
Mhash_Ver='mhash-0.9.9.9'
Mcypt_Ver='mcrypt-2.6.8'
Freetype_Ver='freetype-2.7.1'
Curl_Ver='curl-7.53.1'
Pcre_Ver='pcre-8.40'
Boost_Ver='boost_1_59_0'