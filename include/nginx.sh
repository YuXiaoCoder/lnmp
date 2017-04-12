#!/bin/bash

Install_Nginx_Openssl()
{
    if [ "${Enable_Nginx_Openssl}" = 'y' ]; then
        cd ${cur_dir}/src
        [[ -d "${Openssl_Ver}" ]] && rm -rf ${Openssl_Ver}
        tar -zxf ${Openssl_Ver}.tar.gz
        Nginx_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_Ver}"
    else
        Nginx_With_Openssl=""
    fi
}

Nginx_With_PCRE(){
    cd ${cur_dir}/src
    [[ -d "${Pcre_Ver}" ]] && rm -rf ${Pcre_Ver}
    tar -zxf ${Pcre_Ver}.tar.gz
    Nginx_With_PCRE="--with-openssl=${cur_dir}/src/${Pcre_Ver}"
}

Nginx_With_Zlib(){
    cd ${cur_dir}/src
    [[ -d "${Zlib_Ver}" ]] && rm -rf ${Zlib_Ver}
    tar -zxf ${Zlib_Ver}.tar.gz
    Nginx_With_Zlib="--with-openssl=${cur_dir}/src/${Zlib_Ver}"
}

Install_Nginx()
{
    echo "+------------------------------------------------------------------------+"
    echo -e "${CQUESTION}[+] Installing ${Nginx_Ver}... ${CEND}"
    groupadd -r ${Nginx_Group} && useradd -r -g ${Nginx_Group} -s /sbin/nologin ${Nginx_User}
    cd ${cur_dir}/src
    Install_Nginx_Openssl
    [[ -d "${Nginx_Ver}" ]] && rm -rf ${Nginx_Ver}
    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
    NGINX_FEATURES="--prefix=${Nginx_INSTALL_DIR} \
    --pid-path=/usr/local/nginx/logs/nginx.pid \
    --user=${Nginx_User} \
    --group=${Nginx_Group} \
    --with-pcre=${Nginx_With_PCRE} \
    --with-zlib=${Nginx_With_Zlib} \
    --with-openssl=${Nginx_With_Openssl} \
    --with-http_ssl_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-mail \
    --with-mail_ssl_module \
    --http-client-body-temp-path=/var/tmp/nginx/client \
    --http-proxy-temp-path=/var/tmp/nginx/proxy \
    --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
    --http-scgi-temp-path=/var/tmp/nginx/scgi \
    --with-debug \
    ${Nginx_Modules_Options}
    "
    mkdir -p /var/tmp/nginx/{client,proxy,fastcgi,uwsgi,scgi}
    ./configure ${NGINXFEATURES}
    make -j ${THREAD} && make install
    rm -rf ${cur_dir}/src/{${Nginx_Ver},${Pcre_Ver},${Zlib_Ver},${Openssl_Ver}}

    cd ../
    ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx
    rm -f /usr/local/nginx/conf/nginx.conf
    cd ${cur_dir}
    \cp -f conf/nginx.conf /usr/local/nginx/conf/nginx.conf
    \cp -f conf/enable-php.conf /usr/local/nginx/conf/enable-php.conf
    if [ "${Default_Website_Dir}" != "/data/www" ]; then
        sed -i "s#/data/www#${Default_Website_Dir}#g" /usr/local/nginx/conf/nginx.conf
    fi

    mkdir -p ${Default_Website_Dir}
    touch ${Default_Website_Dir}/index.html
    echo "Hello World!!!" > ${Default_Website_Dir}/index.html
    chmod 755 ${Default_Website_Dir}
    chown -R ${Nginx_User}:${Nginx_Group} ${Default_Website_Dir}
    [[ ! -d /usr/local/nginx/conf/vhost ]] && mkdir -p /usr/local/nginx/conf/vhost

    echo -e "${CMSG}[+] Copy startup script...${CEND}"
    \cp -f init.d/init.d.nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    echo "+------------------------------------------------------------------------+"
    echo -e "|${CSUCCESS}                  Nginx service installed successfully                  ${CEND}|"
    echo "+------------------------------------------------------------------------+"
}