# How To Install ERPNext 15 on Ubuntu 24.04 LTS
A complete Guide on How to Install Frappe/ERPNext version 15 in Ubuntu 24.04 LTS

## Software Requirements
- Updated Ubuntu 24.04
- A user with sudo privileges

## Hardware Requirements
- 4GB RAM
- 32GB Hard Disk

## Pre-requisites
  - Python 3.11+                                  (python 3.12 is inbuilt in Ubuntu 24.04 LTS)
  - Node.js 18+
  - Redis 5                                       (caching and real time updates)
  - MariaDB 10.3.x / Postgres 9.5.x               (External MariaDB setup)
  - yarn 1.12+                                    (js dependency manager)
  - pip 20+                                       (py dependency manager)
  - wkhtmltopdf (version 0.12.5 with patched qt)  (for pdf generation)
  - cron                                          (bench's scheduled jobs: automated certificate renewal, scheduled backups)
  - NGINX                                         (proxying multitenant sites in production)

#### Refer this for default python 3.11 setup

- [D-codeE Video Tutorial] (https://youtu.be/zU41gq7nji4)


> ## Note:
> Ubuntu 24.04 default python version is python3.12
> 
> Ubuntu 24.04 default mariadb version is 10.11

### Update and Upgrade Packages
First, update your package list and upgrade your installed packages to ensure you’re starting with the latest versions.
```
sudo apt update -y && sudo apt upgrade -y
```
### Install ufw 
```
sudo apt install -y ufw
```
```   
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3306/tcp
sudo ufw allow 8000/tcp
sudo ufw reload
```
### Create a new user – (Frappe Bench User)
create a new user for running the Frappe Bench.
```
sudo useradd -m frappe -s /bin/bash
sudo usermod -aG sudo frappe
sudo passwd frappe
su - frappe
```    
### Install git
Git is required for version control and to clone repositories.
```
sudo apt install -y git
```
### Install -y python3-dev 
Install Python 3.12 and its development tools.
```
sudo apt install -y python3-dev 
```
### Install setuptools and pip (Python's Package Manager).
```
sudo apt install -y python3-setuptools python3-pip 
```
### Install virtualenv
Set up a virtual environment for Python 3.12.
``` 
sudo apt install -y python3.12-venv
```
### Install Common Software Properties
Install the necessary software properties.
```
sudo apt install -y software-properties-common 
```    
### Install MariaDB
MariaDB is the database management system used by ERPNext.
```
sudo apt install -y libmariadb-dev mariadb-server pkg-config
```
### Enabling Mariadb boots 
```
sudo systemctl enable mariadb
sudo systemctl start mariadb
```   
### Secure MySQL Installation
```
sudo mariadb-secure-installation
```    
### MySQL database development files
This installs libraries needed to develop and compile MySQL client applications, which are essential for interacting with MySQL databases.
```
sudo apt install -y libmysqlclient-dev mariadb-client
```
### Edit the mariadb configuration ( unicode character encoding )
Open the MySQL configuration file for editing:
```
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Add the following lines to the configuration file:
```
[server]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql
bind-address = 127.0.0.1
query_cache_size = 16M
log_error = /var/log/mysql/error.log
```
```
[mysqld]
innodb-file-format=barracuda
innodb-file-per-table=1
innodb-large-prefix=1
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci      
```
```
[mysql]
default-character-set = utf8mb4
```

### Restart Mariadb 
```
sudo systemctl restart mariadb
```
### Install Redis
Redis is used for caching and background job processing.
```
sudo apt install -y redis-server
```
### Enabling Redis boots 
```
sudo systemctl enable redis-server
sudo systemctl start redis-server
```
### Install Node.js 20.X package
Curl is required for downloading files and setting up Node.js.
```
sudo apt install -y curl 
```
### Install Node.js
Use NVM (Node Version Manager) to install Node.js version 18.
```
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
nvm install 20 
```
### Install Npm and yarn
Install npm, the Node.js package manager.
```
sudo apt install -y npm
```
Install Yarn, a fast and reliable JavaScript package manager.
```
sudo npm install -g yarn
```
### Install wkhtmltopdf
These tools are used to convert HTML pages into PDF files, often for generating reports or documents.
```
sudo apt install -y xvfb libfontconfig wkhtmltopdf
```
###
```
sudo mkdir /opt/erpnext
sudo chown -R frappe:frappe /opt/erpnext
cd /opt/erpnext
```
### Install frappe-bench
Quickly set up your Frappe development environment with this command:
```
sudo -H pip3 install frappe-bench --break-system-packages
bench --version 
```   
### Initialize Frappe Bench with a Specific Version
Initialize Frappe Bench using version 15.
```
bench init frappe-bench --frappe-branch version-15
```
### Switch directories into the Frappe Bench directory
```
cd frappe-bench
```
### Note
> If mariadb is on a separate database server

Set mariadb host
```
bench set-mariadb-host 10.11.12.30
```
Replace amjid with your desired site name. and the IP Address with your ip
```
bench new-site abc.co.rw --db-host 10.11.12.30 --db-port 3306 --db-root-username amjid  --mariadb-user-host-login-scope='%'
```
Provide the MariaDB credentials when prompted.

### Create a new site in frappe bench 

### Note 
> Warning: MariaDB version ['10.11', '7'] is more than 10.8 which is not yet tested with Frappe Framework.
Set up a new site with the following command.
```    
bench new-site abc.co.rw --db-name abc_db
bench --site abc.co.rw add-to-hosts
bench use abc.co.rw
```
### Install Standard and Custom Apps from GitHub(Optional)
> Install a Standard App
To install a standard app from the Frappe ecosystem, run:
```
bench get-app erpnext --branch version-15
bench get-app payments --branch version-15
bench get-app hrms --branch version-15
```
```
bench --site abc.co.rw install-app erpnext
bench --site abc.co.rw install-app payments
bench --site abc.co.rw install-app hrms
```
```    
bench start
```
# Install and Configure Additional Tools
> Install Ansible (Python Package)
> Install Ansible to manage automation tasks.
```
sudo /usr/bin/python3 -m pip install ansible --break-system-packages
```    
### Install Fail2ban
Set up Fail2ban to enhance security.
```
sudo apt install -y fail2ban
sudo systemctl is-enabled fail2ban
```   
### Install and Configure Nginx
> Install Nginx
Update your package list and install Nginx.
```
sudo apt install -y nginx 
sudo systemctl is-enabled nginx
```   
### Install and setup Supervisor
Install Supervisor to manage processes.
```
sudo apt install -y supervisor 
sudo systemctl is-enabled supervisor
```
# Setting ERPNext for Production
Activate the scheduler for your site.
```
bench --site abc.co.rw enable-scheduler
```
> Set Maintenance Mode off
Disable maintenance mode to make your site accessible.
```
bench --site abc.co.rw set-maintenance-mode off
```   
### Setup NGINX and supervisor to apply the changes
```
sudo bench setup supervisor
```
```
sudo bench setup nginx
```
Remove the standard nginx sites. To avoid conflict and to avoid security vunlerabities 
```
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
```
### Set Up Production Environment
Finally, set up the production environment using the following command:
```
sudo bench setup production frappe --yes
bench restart
```
### Set Permissions for the User Directory
Make sure the user has the correct permissions to access their home directory.
```
chmod -R o+rx /opt/erpnext/
bench restart
```
> And that’s it! You’ve successfully installed ERPNext Version 15 on Ubuntu 24. Your system is now ready for use.

### Restart Supervisor and nginx 
```
sudo systemctl restart nginx supervisor
```    
Verify services managed by nginx

```
sudo systemctl status nginx
```
Verify services managed by supervisord
```
sudo supervisorctl status
```

When this completes doing the settings, your instance is now on production mode and can be accessed using your IP, without needing to use the port.

This also will mean that your instance will start automatically even in the event you restart the server.

# Setup Multitenancy
#### DNS based multitenancy 
You can name your sites as the hostnames that would resolve to it. Thus, all the sites you add to the bench would run on the same port and will be automatically selected based on the hostname.

To make a new site under DNS based multitenancy, perform the following steps.

### Switch on DNS based multitenancy (once)
```
bench config dns_multitenant on
```   
### STEP 3 ~ Reload nginx
```
sudo service nginx reload
```
# Adding a Domain with SSL to your Site
### Add Domain
```
bench setup add-domain tenant1.abc.co.rw
```
### Install Let's Encrypt Certificate
#### Install snapd on your machine
```
sudo apt install -y snapd
```
#### Update snapd
```
sudo snap install core;
sudo snap refresh core
```
### Remove existing installations of certbot
```
sudo apt remove certbot
```
### Install certbot
```
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```
### Get Certificate
```
sudo -H bench setup lets-encrypt abc.co.rw
```
You will be faced with several prompts, respond to them accordingly. This command will also add an entry to the crontab of the root user (this requires elevated permissions), that will attempt to renew the certificate every month.

Open url https://abc.co.rw to login 

Default User is Administrator and use password you entered while creating new site.
