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
    sudo adduser frappe
    sudo usermod -aG sudo frappe
    su - frappe
    cd /home/frappe

### STEP 3 Install git
    sudo apt-get install -y git pkg-config

### STEP 4 install python3-dev
    sudo apt-get install -y python3-dev python3-distutils

### STEP 5 Install setuptools and pip (Python's Package Manager).
    sudo apt-get install -y python3-setuptools python3-pip

### STEP 6 Install virtualenv
    sudo apt-get install -y python3-venv 
    
### STEP 7 Install MariaDB
    sudo apt-get install -y software-properties-common 
    sudo apt-get install -y mariadb-server mariadb-client libmariadb-dev 
    
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    
    sudo mysql_secure_installation

### Install Nginx
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx

### Install and setup Supervisor
    sudo apt-get install -y supervisor
    sudo systemctl start supervisor
    sudo systemctl enable supervisor

### Install Fail2ban
    sudo apt-get install -y fail2ban
    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban

### STEP 8  MySQL database development files
    sudo apt-get install -y libmysqlclient-dev

### STEP 9 Open the MariaDB server configuration , Update the bind-address:
    sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

add this to the 50-server.cnf file
    
    [server]
    bind-address = 127.0.0.1

### Then, update character sets for compatibility:
    sudo cat <<EOF > /etc/mysql/my.cnf

    [mysqld]
    character-set-client-handshake = FALSE
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci
     
    [mysql]
    default-character-set = utf8mb4
    EOF

### Now press (Ctrl-X) to exit
    sudo systemctl restart mariadb

### STEP 10 install Redis
    sudo apt-get install -y redis-server
    sudo systemctl start redis-server
    sudo systemctl enable redis-server
    
### STEP 11 install Node.js 23.X package
    sudo apt install -y curl
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    source ~/.profile
    nvm install 23

### STEP 12  install Yarn
    npm install -g npm@11.4.2
    sudo npm install -g yarn 

### STEP 13 install wkhtmltopdf (used for PDF reports in ERPNext)
    sudo apt-get install -y fontconfig libxrender1 xfonts-75dpi xfonts-base
    sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb 
    sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
    sudo apt install -f
    sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
    sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
    sudo apt install -y fontconfig xvfb libfontconfig xfonts-base xfonts-75dpi libxrender1 

    
### Create Python Virtual Environment and Install Frappe Bench
    python3 -m venv myenv
    source myenv/bin/activate

### STEP 14 install frappe-bench
    sudo -H pip3 install frappe-bench --break-system-packages
    sudo -H pip3 install ansible --break-system-packages
    bench --version
    
### STEP 15 initilise the frappe bench & install frappe latest version 
    bench init frappe-bench --frappe-branch version-15
    cd frappe-bench/
    sudo chmod -R o+rx /home/frappe
    sudo chown -R frappe:frappe /home/frappe/frappe-bench
    
### STEP 16 create a site in frappe bench 

>### Note 
> Warning: MariaDB version ['10.11', '7'] is more than 10.8 which is not yet tested with Frappe Framework.
    
    bench new-site dcode.com
    bench --site dcode.com add-to-hosts

### STEP 17 install ERPNext latest version in bench & site apps

    bench get-app --branch version-15 erpnext
    bench --site dcode.com install-app erpnext

    bench get-app hrms
    bench --site dcode.com install-app hrms

    bench get-app payments
    bench --site dcode.com install-app payments

    bench get-app non_profit
    bench --site dcode.com install-app non_profit

    bench get-app ury https://github.com/ury-erp/ury.git
    bench --site dcode.com install-app ury

    bench get-app https://github.com/erpchampions/uganda_compliance
    bench --site dcode.com install-app uganda_compliance

    bench --site dcode.com build
    bench --site dcode.com migrate
    
## Setting ERPNext for Production

### STEP 18 Enable Scheduler and Disable Maintenance Mode   
    bench --site dcode.com enable-scheduler
    bench --site dcode.com set-maintenance-mode off

### STEP 19 Setup production config
    sudo bench setup production frappe
    bench config dns_multitenant on
    
### STEP 20 Setup NGINX to apply the changes
    bench setup nginx

### Restart Supervisor and Launch Production Mode
    sudo supervisorctl restart all
    sudo service nginx restart
    sudo bench setup production frappe
    bench restart

### STEP 21 Install Letsencrypt ssl certificate 
    sudo apt-get install -y snapd
    sudo snap install core 
    sudo snap refresh core 
    sudo apt-get remove certbot -y
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot 
    sudo certbot --nginx -d dcode.com
    bench use dcode.com
    
### Update bench itself
    bench update

Open url https://dcode.com without the port to login

    
