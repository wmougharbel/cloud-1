FROM alpine:3.20

RUN apk add --no-cache \
    curl \
    mariadb-client \
    unzip \
    bash \
    php83-fpm \
    php83-mysqli \
    php83-cli \
    php83-curl \
    php83-gd \
    php83-mbstring \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-iconv \
    php83-openssl \
    php83-tokenizer \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-pecl-imagick \
    php83-intl

RUN echo "memory_limit = 512M" > /etc/php83/conf.d/docker-php-memory.ini

RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's|user = nobody|user = www-data|' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's|group = nobody|group = www-data|' /etc/php83/php-fpm.d/www.conf

RUN mkdir -p /var/www/html/wp-content/mu-plugins && \
    echo "<?php add_filter('pre_http_request', function(\$p, \$a, \$u) { return (strpos(\$u, 'http://localhost') === 0) ? wp_remote_request(str_replace('http://localhost', 'http://nginx', \$u), \$a) : \$p; }, 10, 3);" \
    > /var/www/html/wp-content/mu-plugins/docker-loopback-fix.php && \
    chown -R www-data:www-data /var/www/html/wp-content/mu-plugins

COPY auto-install.sh /usr/local/bin/auto-install.sh
RUN chmod +x /usr/local/bin/auto-install.sh

EXPOSE 9000

ENTRYPOINT ["auto-install.sh"]