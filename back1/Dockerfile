FROM nanoninja/php-fpm:latest

COPY ./php-fpm.conf /usr/local/etc/
COPY ./site.conf /usr/local/etc/php-fpm.d/

CMD ["php-fpm", "-F"]
