FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    libldap2-dev \
    ghostscript \
    cron \
    git \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configurar e instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        zip \
        intl \
        xml \
        xsl \
        mbstring \
        soap \
        ldap \
        opcache \
        exif

# Instalar extensões adicionais via PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

# Configurar PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Baixar e instalar Moodle 4.5.6
WORKDIR /tmp
RUN wget https://download.moodle.org/download.php/direct/stable456/moodle-4.5.6.tgz \
    && tar -xzf moodle-4.5.6.tgz \
    && mv moodle/* /var/www/html/ \
    && rm -rf moodle* \
    && chown -R www-data:www-data /var/www/html

# Criar diretório de dados do Moodle
RUN mkdir -p /var/moodledata \
    && chown -R www-data:www-data /var/moodledata \
    && chmod -R 755 /var/moodledata

# Configurar crontab para Moodle
RUN echo "* * * * * www-data /usr/local/bin/php /var/www/html/admin/cli/cron.php >/dev/null" >> /etc/crontab

# Script de inicialização
COPY ./scripts/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["init.sh"]
