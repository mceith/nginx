#!/bin/bash
set -e

PHPFPM_CONF_FILE="/etc/php-fpm.d/www.conf"
NGINX_CONF_FILE="/etc/nginx/nginx.conf"
INDEX="/var/www/$DOMAIN/public_html/index.php"

configure_nginx() {

        sed -ie "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm\/php-fpm.sock/" $PHPFPM_CONF_FILE
        sed -ie "s/;listen.owner = nobody/listen.owner = nobody/" $PHPFPM_CONF_FILE
        sed -ie "s/;listen.group = nobody/listen.group = nobody/" $PHPFPM_CONF_FILE
        sed -ie "s/apache/${PHP_USER}/" $PHPFPM_CONF_FILE
        sed -ie "s/DBADDR/oc/" $INDEX

}

if [ ! -d "/var/www/$DOMAIN" ]; then
  mkdir -p /var/www/$DOMAIN/public_html
  mkdir -p /var/www/example.com/public_html
fi

if [ ! -f "/etc/nginx/conf.d/${DOMAIN}.conf" ]; then

        TEMP_FILE="/etc/nginx/conf.d/${DOMAIN}.conf"
		cat > "$TEMP_FILE" <<-EOL
			server {
			server_name www.$DOMAIN;
			access_log /var/wwwlogs/access_www.$DOMAIN;
			error_log /var/wwwlogs/error_www.$DOMAIN;
			root /var/www/$DOMAIN/public_html;
			set_real_ip_from  10.1.0.1;
			real_ip_header    X-Forwarded-For;

			location / {
			index index.html index.htm index.php;
			}
			
			location ~ \.php\$ {
				include /etc/nginx/fastcgi_params;
				fastcgi_pass  unix:/var/run/php-fpm/php-fpm.sock; 
				fastcgi_index index.php;
				fastcgi_param SCRIPT_FILENAME /var/www/$DOMAIN/public_html\$fastcgi_script_name;
			}
			}
		EOL

    if [ ! -f "/var/www/${DOMAIN}/public_html/index.php" ]; then
    mv /index.php /var/www/${DOMAIN}/public_html/
    fi
    configure_nginx
    /usr/sbin/php-fpm -D && exec /usr/sbin/nginx -g "daemon off;"
else
    /usr/sbin/php-fpm -D && exec /usr/sbin/nginx -g "daemon off;"
fi
