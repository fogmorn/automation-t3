FROM nanoninja/php-fpm:latest

COPY ./back1/php-fpm.conf /usr/local/etc/
COPY ./back1/site.conf /usr/local/etc/php-fpm.d/
COPY ./site_static/multiply.php /var/www/html/site/
COPY ./site_static/add.php /var/www/html/site/
COPY ./site_static/index.html /var/www/html/site/

CMD ["php-fpm", "-F"]
