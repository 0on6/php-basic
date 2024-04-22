FROM ubuntu:22.04
USER root

# Set working directory
ENV  APPPATH=/var/www/dev/api/current
WORKDIR ${APPPATH}
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -y
RUN apt upgrade -y
RUN apt install rsync openssh-client curl zip unzip wget -y

RUN apt -y install software-properties-common
RUN add-apt-repository -y ppa:ondrej/nginx
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN dpkg --configure -a
RUN apt --fix-broken install
RUN apt update
RUN apt -y install php7.2 php7.2-fpm
RUN apt -y install php7.2-mysql php7.2-mbstring php7.2-xml php7.2-gd php7.2-curl



# Install dependencies
RUN apt install -y \
    build-essential \
    libpng-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    php7.2-gd \
    php7.2-intl \
    php7.2-mysql \
    php7.2-mbstring \
    php7.2-xml \
    php7.2-curl \
    php7.2-common \
    php7.2-cli \
    php7.2-bcmath \
    php7.2-zip \
    php7.2-pgsql \
    php7.2-redis 

RUN apt install nginx -y
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Configure Nginx
RUN rm /etc/nginx/sites-enabled/default
RUN mkdir -p /var/www/dev/web-front-end/current
RUN mkdir -p /var/www/dev/api/current
COPY nginx/dev /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/dev /etc/nginx/sites-enabled/dev

# Configure PHP
COPY ./php/local.ini /usr/local/etc/php/conf.d/local.ini

# Clear cache
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt update -y
RUN apt install php7.2-imagick -y 
RUN echo "extension=imagick.so;" >> /etc/php/7.2/cli/php.ini

# Start php-fpm and nginx server
CMD service php7.2-fpm start && nginx
