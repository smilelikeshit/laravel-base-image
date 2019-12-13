FROM php:7.2-apache-stretch

WORKDIR /var/www/html
#COPY . /var/www/html

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install curl -y

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.5.0

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v && npm -v

# Install package for php
RUN apt-get install -y libxml2-dev libzip-dev libpq-dev libmcrypt-dev libmagickwand-dev libreadline-dev libssl-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev git zip --no-install-recommends \
        && pecl install mcrypt-1.0.2 \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-configure zip --with-libzip \ 
        && docker-php-ext-install pdo_mysql pdo_pgsql pgsql gd xml zip \
        && docker-php-ext-enable mcrypt \ 
        && apt-get purge -y \
        && rm -r /var/lib/apt/lists/* \ 
        && a2enmod rewrite 
        
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '106d3d32cc30011325228b9272424c1941ad75207cb5244bee161e5f9906b0edf07ab2a733e8a1c945173eb9b1966197') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" 
    #&& php composer.phar install --no-dev --no-scripts 
    #&& php composer.phar update

EXPOSE 80
