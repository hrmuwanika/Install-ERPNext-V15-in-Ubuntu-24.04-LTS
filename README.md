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
    sudo adduser rappe-user
    sudo usermod -aG sudo frappe-user
    su frappe-user
    cd /home/frappe-user

### STEP 3 Install git
    sudo apt-get install git -y

### STEP 4 install python-dev
    sudo apt-get install python3-dev -y

### STEP 5 Install setuptools and pip (Python's Package Manager).
    sudo apt-get install python3-setuptools python3-pip -y

### STEP 6 Install virtualenv
    sudo apt install python3.12-venv -y
    
### STEP 7 Install MariaDB
    sudo apt-get install software-properties-common -y
    sudo apt install mariadb-server -y
    
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    
    sudo mysql_secure_installation

    
### STEP 8  MySQL database development files
    sudo apt-get install libmysqlclient-dev -y

### STEP 9 Edit the mariadb configuration ( unicode character encoding )
    sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

add this to the 50-server.cnf file
    
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
    
    [mysqld]
    innodb-file-format=barracuda
    innodb-file-per-table=1
    innodb-large-prefix=1
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
    bench start
    
Deploying ERPNext in Production Mode

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



    
