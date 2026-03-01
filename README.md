# Frappe-ERPNext Version-15 in Ubuntu 24.04 LTS
A complete Guide to Install Frappe/ERPNext version 15  in Ubuntu 24.04 LTS


#### Refer this for default python 3.11 setup

- [D-codeE Video Tutorial](https://youtu.be/zU41gq7nji4)

### Pre-requisites 

      Python 3.11+                                  (python 3.12 is inbuilt in 24.04 LTS)
      Node.js 18+
      
      Redis 5                                       (caching and real time updates)
      MariaDB 10.3.x / Postgres 9.5.x               (to run database driven apps)
      yarn 1.12+                                    (js dependency manager)
      pip 20+                                       (py dependency manager)
      wkhtmltopdf (version 0.12.5 with patched qt)  (for pdf generation)
      cron                                          (bench's scheduled jobs: automated certificate renewal, scheduled backups)
      NGINX                                         (proxying multitenant sites in production)


> ## Note:
> ubuntu 24.04 default python version is python3.12
> ubuntu 24.04 default mariadb version is 10.11

### STEP 1 Update and Upgrade Packages
    sudo apt-get update -y && sudo apt-get upgrade -y

### STEP 2 Create a New Sudo User
    sudo adduser frappe-user
    sudo usermod -aG sudo frappe-user
    su frappe-user
    cd /home/frappe-user

### STEP 3 Install git
    sudo apt-get install git -y

### STEP 4 install python-dev
    sudo apt-get install python3-dev python3.12-dev -y

### STEP 5 Install setuptools and pip (Python's Package Manager).
    sudo apt-get install python3-setuptools python3-pip -y

### STEP 6 Install virtualenv
    sudo apt-get install python3.12-venv -y
    
### STEP 7 Install MariaDB
    sudo apt-get install software-properties-common -y
    sudo apt-get install mariadb-server mariadb-client -y
    
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    
    sudo mysql_secure_installation

### Install Nginx
    sudo apt-get install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

### Install and setup Supervisor
    sudo apt-get install supervisor -y
    sudo systemctl start supervisor
    sudo systemctl enable supervisor

### Install Fail2ban
    sudo apt-get install fail2ban -y
    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban

### STEP 8  MySQL database development files
    sudo apt-get install libmysqlclient-dev -y

### STEP 9 Edit the mariadb configuration ( unicode character encoding )
    sudo nano /etc/mysql/my.cnf

add this to the my.cnf file
    
    [mysqld]
    character-set-client-handshake = FALSE
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci
  
    [mysql]
    default-character-set = utf8mb4

### Now press (Ctrl-X) to exit
    sudo service mysql restart

### STEP 10 install Redis
    sudo apt-get install redis-server -y
    sudo systemctl start redis-server
    sudo systemctl enable redis-server
    
### STEP 11 install Node.js 18.X package
    sudo apt install curl -y
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.profile
    nvm install 18

### STEP 12  install Yarn
    sudo apt-get install npm -y
    sudo npm install -g yarn -y

### STEP 13 install wkhtmltopdf
    sudo apt-get install xvfb libfontconfig wkhtmltopdf -y

### STEP 14 install frappe-bench
    sudo -H pip3 install frappe-bench --break-system-packages
    sudo -H pip3 install ansible --break-system-packages
    bench --version
    
### STEP 15 initilise the frappe bench & install frappe latest version 
    bench init frappe-bench --frappe-branch version-15
    cd frappe-bench/
    chmod -R o+rx /home/frappe-user
    bench start
    
### STEP 16 create a site in frappe bench 

>### Note 
>Warning: MariaDB version ['10.11', '7'] is more than 10.8 which is not yet tested with Frappe Framework.
    
    bench new-site dcode.com
    bench --site dcode.com add-to-hosts

Open url http://dcode.com:8000 to login 


### STEP 17 install ERPNext latest version in bench & site

    bench get-app erpnext --branch version-15
    bench --site dcode.com install-app erpnext

    bench get-app hrms
    bench --site dcode.com install-app hrms

    bench get-app payments
    bench --site dcode.com install-app payments

    bench get-app non_profit
    bench --site dcode.com install-app non_profit

    bench get-app https://github.com/erpchampions/uganda_compliance
    bench --site dcode.com install-app uganda_compliance

    bench --site dcode.com migrate
    bench use dcode.com
    bench start
    
Setting ERPNext for Production

### STEP 18 Enable Scheduler and Disable Maintenance Mode   
    bench --site dcode.com enable-scheduler
    bench --site dcode.com set-maintenance-mode off

### STEP 19 Setup Production Config
    sudo bench setup production frappe-user
    bench setup nginx

### STEP 20 Restart Supervisor:
    sudo supervisorctl restart all
    sudo bench setup production frappe-user

Open url http://dcode.com without the port to login

### STEP 21 Install Letsencrypt ssl certificate 
    sudo apt install snapd -y
    sudo snap install core; sudo snap refresh core 
    sudo apt-get remove certbot -y
    sudo snap install --classic certbot sudo ln -s /snap/bin/certbot /usr/bin/certbot 
    sudo certbot --nginx -d dcode.com
    

Open url https://dcode.com without the port to login

    
