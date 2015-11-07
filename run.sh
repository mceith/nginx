#!/bin/bash
set -e

PHPFPM_CONF_FILE="/etc/php-fpm.d/www.conf"
NGINX_CONF_FILE="/etc/nginx/nginx.conf"
INDEX="/var/www/example.com/public_html/index.php"

configure_nginx() {

        sed -ie "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm\/php-fpm.sock/" $PHPFPM_CONF_FILE
        sed -ie "s/;listen.owner = nobody/listen.owner = nobody/" $PHPFPM_CONF_FILE
        sed -ie "s/;listen.group = nobody/listen.group = nobody/" $PHPFPM_CONF_FILE
        sed -ie "s/apache/${PHP_USER}/" $PHPFPM_CONF_FILE
        sed -ie "s/DBADDR/${OC_PORT_6379_TCP_ADDR}/" $INDEX

}
if [ ! -f "/etc/nginx/conf.d/${DOMAIN}.conf" ]; then

        TEMP_FILE="/etc/nginx/conf.d/${DOMAIN}.conf"
		cat > "$TEMP_FILE" <<-\EOL
			server {
			server_name www.example.com;
			access_log /var/wwwlogs/access_www.example.com;
			error_log /var/wwwlogs/error_www.example.com;
			root /var/www/example.com/public_html;
			real_ip_header    X-Forwarded-For;
		  proxy_set_header        X-Real-IP       $remote_addr;
			proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;

			location / {
			index index.html index.htm index.php;
			}
			
			location ~ \.php$ {
				include /etc/nginx/fastcgi_params;
				fastcgi_pass  unix:/var/run/php-fpm/php-fpm.sock; 
				fastcgi_index index.php;
				fastcgi_param SCRIPT_FILENAME /var/www/example.com/public_html$fastcgi_script_name;
			}
			}
		EOL

                configure_nginx
		/usr/sbin/php-fpm -D && exec /usr/sbin/nginx -g "daemon off;"
else
		/usr/sbin/php-fpm -D && exec /usr/sbin/nginx -g "daemon off;"
fi
