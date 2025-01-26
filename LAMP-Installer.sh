#!/bin/env bash

if [ $EUID -ne 0 ]; then
	echo "execute this script as root..."
	exit 1
fi
#########################################
############## FUNCTIONS ################
#########################################

is_installed() {
	pacman -Qq "$1" &> /dev/null
}

#########################################
######### UPDATE REPOSITORIES ###########
#########################################
echo "Updating repositories..."
pacman -Sy &> /dev/null
echo "Repo updated :D"
sleep .5

#########################################
########### PACKAGES NEEDED #############
#########################################

packages=(apache php php-apache mariadb phpmyadmin figlet toilet lolcat)

clear
for pack in "${packages[@]}"; do
	if ! is_installed "$pack"; then
		echo "Installing $pack..."
		if pacman -S "$pack" --noconfirm &> /dev/null; then
			echo "The package $pack is installed :D"
		else
			echo "Error ocurred while installing $pack!!!"
		fi
	else
		echo "The package $pack is already installed..."
	fi
done

#########################################
################ BANNER #################
#########################################

clear
toilet -f slant -F border -d /usr/share/figlet/fonts "LAMP Installer" | lolcat
echo "by XxAlex_plosivoxX (Only works in Arch Linux...)" | lolcat
sleep 1

#########################################
############### SERVICES ################
#########################################

echo -n "do you want to enable the apache service? (y/n): "
read siono

if [ $siono == "y" -o $siono == "Y" ]; then
	echo "Enabling and starting..."
	systemctl enable httpd
	systemctl start httpd

elif [ $siono == "n" -o $siono == "N" ]; then
	echo "Skipping..."

else
	echo "Invalid answer..."
	exit 1
fi

#########################################
############## PERMISSIONS ##############
#########################################

chmod -R 777 /srv/http

#########################################
############## CONFIGURING ##############
#########################################
echo "backup of php.ini is /etc/php/php.ini.save"
cp /etc/php/php.ini /etc/php/php.ini.save

echo "configuring php..."
sed -i '/;extension=pdo_mysql/s/^;//g' /etc/php/php.ini
sleep 0.5
sed -i '/;extension=mysqli/s/^;//g' /etc/php/php.ini
sleep 0.5
sed -i '/;session.save_path/s/^;//g' /etc/php/php.ini
sleep 0.5

echo "backup of httpd.conf is /etc/httpd/conf/httpd.conf.save"
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.save

echo "Configuring apache and phpmyadmin..."
sed -i '/#LoadModule mpm_prefork_module /s/^#//g' /etc/httpd/conf/httpd.conf
sleep 0.5
sed -i '/LoadModule mpm_event_module /s/^/#/g' /etc/httpd/conf/httpd.conf
sleep 0.5
echo "LoadModule php_module modules/libphp.so
AddHandler php-script .php
Include	conf/extra/php_module.conf
Include conf/extra/phpmyadmin.conf" >> /etc/httpd/conf/httpd.conf

echo "Configuring mariadb..."
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql &> /dev/null
echo 'Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
<Directory "/usr/share/webapps/phpMyAdmin">
    DirectoryIndex index.php
    AllowOverride All
    Options FollowSymlinks
    Require all granted
</Directory>' > /etc/httpd/conf/extra/phpmyadmin.conf

echo "restarting services..."
systemctl enable --now mariadb
systemctl restart httpd


