#!/bin/bash
# ====================================================================================================
# title          : installdrupal8.sh
# description    : This script will install Drupal 8 on a new user account created in CentOS 7 CWP
#                : (Control Web Panel).  This script must be run with elevated privileges.
#                : Please read Drupal_8_Setup.pdf for important details about this script
# author         : Cory Hilliard
# date           : 2019.08.15
# version        : 0.1    
# usage          : bash installdrupal8.sh
# ====================================================================================================

# These four variables need to be changed to line up with the usernames and passwords of your site
USERNAME="example"              # this is the username of the user you set up in Part I of Drupal_8_Setup.pdf
PASSWORD="Example123"           # this is the password of the user you set up in Part I of Drupal_8_Setup.pdf
DBNAME="drupal8"                # this will be converted to "example_drupal8" in the mySQL script
DBROOTPASS="EUZn&wo8qBo$VDm"    # this is the root password of your database

mysql -u root -p"${DBROOTPASS}" <<MYSQL_SCRIPT
DROP DATABASE IF EXISTS ${USERNAME}_${DBNAME};
CREATE DATABASE ${USERNAME}_${DBNAME};
GRANT ALL PRIVILEGES ON ${USERNAME}_${DBNAME}.* TO '${USERNAME}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Change directory to the user's root folder
cd /home/${USERNAME}/

# Download Drupal 8.7.6
wget https://ftp.drupal.org/files/projects/drupal-8.7.6.tar.gz

# Extract Drupal
tar -xzvf drupal-8.7.6.tar.gz

# Remove public_html for simplicity
rm -rf public_html

# Rename the extracted drupal folder to public_html
mv drupal-8.7.6 public_html

# Change ownership of the public_html folder and its contents
chown -R ${USERNAME}:${USERNAME} public_html

# Delete the Drupal download
rm drupal-8.7.6.tar.gz -f

# Change file permissions on all subdirectories
echo "Changing folder permissions, this may take a minute"
find /home/${USERNAME}/public_html -type d -exec chmod 755 {} \;

# Change file permissions on all subfiles
echo "Changing file permissions, this may take a minute"
find /home/${USERNAME}/public_html -type f -exec chmod 644 {} \;

# Change directory to the sites/default
cd /home/${USERNAME}/public_html/sites/default

# Remove these two files if they exist
rm -f {settings.php,services.yml}

# Create new settings and services files
cp default.settings.php settings.php && cp default.services.yml services.yml

# Change ownership of settings and services
chown ${USERNAME}:${USERNAME} {settings.php,services.yml}

# Change permissions of settings and services
chmod 777 {services.yml,settings.php}

# Change directory to the web root
cd /home/${USERNAME}/public_html

# Make sites/default writeable for Drupal to work its magic
chmod 777 ./sites/default/

# Edit the .htaccess file of the user's web root
sed -i -e "16s|Options -Indexes|# Options -Indexes|g" .htaccess
sed -i -e "123s|# RewriteBase /|RewriteBase /~${USERNAME}|g" .htaccess

echo " "
echo "***Don't forget!  After you install Drupal, run these two commands again to fix permissions"
echo " "
echo "find /home/${USERNAME}/public_html -type d -exec chmod 755 {} \;"
echo "find /home/${USERNAME}/public_html -type f -exec chmod 644 {} \;"
echo " "