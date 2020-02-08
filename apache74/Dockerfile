FROM php:7.4-apache-stretch

WORKDIR /var/www/html

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install package for php
RUN apt-get update && apt-get install -y libxml2-dev \
        libzip-dev libpq-dev \
        libmcrypt-dev \
        libmagickwand-dev \
        libreadline-dev \
        libssl-dev zlib1g-dev \
        libpng-dev libjpeg-dev \
        libfreetype6-dev \
        git \
        zip \
        cron \
        vim \
        --no-install-recommends \
        && pecl install mcrypt-1.0.2 \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-configure zip --with-libzip \ 
        && docker-php-ext-install pdo_mysql pdo_pgsql pgsql gd xml zip mbstring exif \
        && docker-php-ext-enable mcrypt \ 
        && apt-get purge -y \
        && rm -r /var/lib/apt/lists/* 

# Enable rewrite module apache #
RUN a2enmod rewrite && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN  sed -i -e 's/expose_php = On/expose_php = Off/' /usr/local/etc/php/php.ini
RUN echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
RUN echo "ServerSignature Off" >> /etc/apache2/apache2.conf


# add composer.phar 
ADD composer.phar /var/www/html/
RUN  php composer.phar -V 

EXPOSE 80