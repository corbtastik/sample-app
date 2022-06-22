FROM registry.redhat.io/ubi8/httpd-24:1-193.1654147964

# Add application sources
ADD frontend/build/ /var/www/html/

# The run script uses standard ways to run the application
CMD run-httpd