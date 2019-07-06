#!/bin/bash

systemctl restart php-fpm 
systemctl restart php56-php-fpm 
systemctl restart php70-php-fpm 
systemctl restart php71-php-fpm 
systemctl restart php72-php-fpm 
systemctl restart php73-php-fpm 
systemctl restart php74-php-fpm 

systemctl restart httpd