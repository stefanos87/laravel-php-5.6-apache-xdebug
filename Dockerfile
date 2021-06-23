FROM php:5.6-apache
LABEL   version="1.0" \
        author="Stefano Stirati" \
        email="stefano.stirati@gmail.com"

RUN apt-get update && \
    apt-get -y install \
        gnupg2 && \
    apt-key update && \
    apt-get update && \
    apt-get -y install \
            g++ \
            wget \
            git \
            curl \
            imagemagick \
            libcurl3-dev \
            libicu-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev -qy \
            libonig-dev \
            libmagickwand-dev \
            libpq-dev \
            libpng-dev \
            libxml2-dev \
            libzip-dev \
            zlib1g-dev \
            default-mysql-client \
            openssh-client \
            nano \
            vim \
            unzip \
            libcurl4-openssl-dev \
            libssl-dev \
            libldap2-dev \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG X_LEGACY_GD_LIB=1
RUN if [ $X_LEGACY_GD_LIB = 1 ]; then \
        docker-php-ext-configure gd \
                --with-freetype-dir=/usr/include/ \
                --with-png-dir=/usr/include/ \
                --with-jpeg-dir=/usr/include/; \
    else \
        docker-php-ext-configure gd \
                --with-freetype=/usr/include/ \
                --with-jpeg=/usr/include/; \
    fi && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo_mysql \
        pdo_pgsql

#Installing LDAP
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap

#Installing composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#Installing node
RUN curl -sL https://deb.nodesource.com/setup_11.x |  bash -
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential
RUN npm install --global gulp-cli


#cromium driver
# RUN wget https://chromedriver.storage.googleapis.com/91.0.4472.101/chromedriver_linux64.zip -P ~/
# RUN unzip ~/chromedriver_linux64.zip -d ~/
# RUN rm ~/chromedriver_linux64.zip
# RUN mv -f ~/chromedriver /usr/local/bin/chromedriver
# RUN chmod 0755 /usr/local/bin/chromedriver
# RUN Xvfb -ac :0 -screen 0 1280x1024x16 &

#chrome
# RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
# RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
# RUN apt-get update 
# RUN apt-get install google-chrome-stable

#DUSK
#RUN apt-get install -y libxpm4 libxrender1 chromium libgtk2.0-0 libnss3 libgconf-2-4 xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable x11-apps
RUN apt-get install -y libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable x11-apps
#CHROME
RUN apt-get install -y libxss1 libappindicator1 libindicator7
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome*.deb 


RUN apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Configure apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

RUN mkdir /var/www/html/sessioni

RUN echo 'date.timezone = GMT' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_log = /var/log/apache2/error.log' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'log_errors = On' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'display_errors = Off' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'post_max_size = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'upload_max_filesize = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_execution_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_input_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_size = 4096K' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_ttl = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'mbstring.func_overload = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_cookies = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.cookie_httponly = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_trans_sid = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.save_handler = files' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.save_path = "/var/www/html/sessioni"' >> /usr/local/etc/php/conf.d/docker.ini


#COPY info.php /var/www/html/info.php

RUN chown -R www-data:www-data /var/www
#Xdebug
#RUN pecl install xdebug 
RUN pecl install xdebug-2.4.1
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# Set up entrypoint enabling host.docker.internal for Linux
#COPY ./entrypoint.sh /usr/bin/entrypoint.sh
#RUN chmod 777 /usr/bin/entrypoint.sh
#ENTRYPOINT ["/usr/bin/entrypoint.sh"]
#CMD ["apache2-foreground"]
