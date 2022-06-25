FROM registry.redhat.io/ubi8/httpd-24:1-193.1654147964
ADD backend/ /var/www/html
CMD run-httpd