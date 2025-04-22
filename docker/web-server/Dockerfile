ARG PROJECT_PHP_VERSION=8.3
FROM php:${PROJECT_PHP_VERSION}-apache
RUN a2enmod rewrite
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
        sendmail \
        libpng-dev \
        zlib1g-dev \
        libzip-dev \
        zip \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev

RUN docker-php-ext-install zip && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install exif && \
    docker-php-ext-install pdo pdo_mysql

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./php.ini /usr/local/etc/php/conf.d/custom-php.ini

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn

ARG USER_NAME=root
RUN useradd -ms /bin/bash ${USER_NAME}
USER ${USER_NAME}