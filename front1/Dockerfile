FROM nginx:latest
EXPOSE 80

RUN rm /etc/nginx/conf.d/default.conf

COPY --chown=root:nginx ./site_static/multiply.php /var/www/html/site/
COPY --chown=root:nginx ./site_static/add.php /var/www/html/site/
COPY --chown=root:nginx ./site_static/index.html /var/www/html/site/
COPY ./nginx_conf/site.conf /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;"]
