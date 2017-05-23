#!/bin/sh

#######################################
# Bash script to install LEMP Stack Installation Script. For Debian based systems.
# Written by @HuongNX

# In case of any errors (e.g. MySQL) just re-run the script. Nothing will be re-installed except for the packages with errors.
#######################################

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Update packages and Upgrade system, Install "software-properties-common" (for the "add-apt-repository")
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo  apt-get update && apt-get install -y \
    software-properties-common locales
    
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

## Add the "PHP 7" ppa
echo -e "$Cyan /n Add the PHP 7 ppa"
sudo add-apt-repository -y \
    ppa:ondrej/php

## Install PHP-CLI 7, some PHP extentions and some useful Tools with APT
echo -e "$Cyan \n Install PHP-CLI 7, some PHP extentions and some useful Tools with APT $Color_Off"
sudo apt-get update && apt-get install -y --force-yes \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-json \
        php7.0-xml \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-pgsql \
        php7.0-sqlite \
        php7.0-sqlite3 \
        php7.0-zip \
        php7.0-memcached \
        php7.0-gd \
        php7.0-fpm \
        php7.0-xdebug \
        php7.1-bcmath \
        php7.1-intl \
        php7.0-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        sqlite3 \
        libsqlite3-dev \
        git \
        curl \
        vim \
        nano \
        net-tools \
        pkg-config \
        iputils-ping

# remove load xdebug extension (only load on phpunit command)
echo -e "$Cyan \n remove load xdebug extension (only load on phpunit command) $Color_Off"
RUN sed -i 's/^/;/g' /etc/php/7.0/cli/conf.d/20-xdebug.ini

# Add bin folder of composer to PATH.
echo -e "$Cyan \n Add bin folder of composer to PATH $Color_Off"
RUN echo "export PATH=${PATH}:/var/www/laravel/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

# Load xdebug Zend extension with phpunit command
RUN echo "alias phpunit='php -dzend_extension=xdebug.so /var/www/laravel/vendor/bin/phpunit'" >> ~/.bashrc

# Install Nodejs
echo -e "$Cyan \n Install Nodejs $Color_Off"
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g gulp-cli bower eslint babel-eslint eslint-plugin-react yarn

# Install SASS
echo -e "$Cyan \n Install SASS $Color_Off"
RUN apt-get install -y ruby \
    && gem install sass

# Install Composer, PHPCS and Framgia Coding Standard,
# PHPMetrics, PHPDepend, PHPMessDetector, PHPCopyPasteDetector
echo -e "$Cyan \n Install Composer, PHPCS and Framgia Coding Standard, PHPMetrics, PHPDepend, PHPMessDetector, PHPCopyPasteDetector $Color_Off"
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require 'squizlabs/php_codesniffer=2.9' \
        'phpmetrics/phpmetrics' \
        'pdepend/pdepend' \
        'phpmd/phpmd' \
        'sebastian/phpcpd' \
    && cd ~/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards/ \
    && git clone https://github.com/wataridori/framgia-php-codesniffer.git Framgia

# Create symlink
RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs \
    && ln -s /root/.composer/vendor/bin/pdepend /usr/bin/pdepend \
    && ln -s /root/.composer/vendor/bin/phpmetrics /usr/bin/phpmetrics \
    && ln -s /root/.composer/vendor/bin/phpmd /usr/bin/phpmd \
    && ln -s /root/.composer/vendor/bin/phpcpd /usr/bin/phpcpd

echo -e "$Cyan \n Installing MySQL $Color_Off"
sudo apt-get install mysql-server mysql-client libmysqlclient15.dev -y

echo -e "$Cyan \n Installing phpMyAdmin $Color_Off"
sudo apt-get install phpmyadmin -y

echo -e "$Cyan \n Verifying installs$Color_Off"
sudo apt-get install nginx php-pear php-mysql mysql-client mysql-server -y

## TWEAKS and Settings
# Permissions
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
sudo chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Restart Nginx
echo -e "$Cyan \n Restarting Nginx $Color_Off"
sudo service nginx restart
