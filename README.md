# LAMP-installer
a script to install a LAMP server on Arch Linux
<div>
  <img src="screenshot.png">
</div>


## Installation and execution

```
curl -LO https://raw.githubusercontent.com/XxAlexplosivoxX/LAMP-installer/refs/heads/main/LAMP-Installer.sh
chmod +x LAMP-Installer.sh
sudo ./LAMP-Installer.sh
```
after the execution you must create the account for mariadb

### Connect to mysql server from your root systemuser via socket (no password required)
```
mysql --protocol=socket  #run this command as root (e.g. prefixed with sudo)
```

### Create the new user
```
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
```

### Create new database and grant privilleges

```
CREATE DATABASE `db_name`;
GRANT ALL PRIVILEGES ON `db_name` . * TO 'username'@'localhost';
```

