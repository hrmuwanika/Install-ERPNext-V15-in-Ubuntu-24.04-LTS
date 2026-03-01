#!/bin/bash

# =================================================================
# EFRIS OFFLINE INSTALLER - FULL AUTOMATED SETUP
# OS: Ubuntu 22.04 | Java 8 | MySQL 8.0 | Tomcat 8.5 | JDBC 5.1
# =================================================================

# --- CONFIGURATION ---
DB_NAME="efris_db"
DB_USER="efris_user"
DB_PASS="Efris@2026_Secure"
TOMCAT_VER="8.5.99"
JAVA_HOME_PATH="/usr/lib/jvm/java-8-openjdk-amd64"
JDBC_VER="5.1.49"

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root: sudo ./efris_full_setup.sh" 
   exit 1
fi

set -e

echo ">>> 1. Updating Repositories & Installing Java 8..."
apt update && apt upgrade -y
apt install -y openjdk-8-jdk mysql-server wget curl

echo ">>> 2. Configuring MySQL (EFRIS Compatibility Mode)..."
systemctl start mysql
# Note: Using mysql_native_password for Java 8 JDBC compatibility
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo ">>> 3. Installing Apache Tomcat ${TOMCAT_VER}..."
wget -q "https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz" -P /tmp
mkdir -p /opt/tomcat
tar xzf /tmp/apache-tomcat-${TOMCAT_VER}.tar.gz -C /opt/tomcat --strip-components=1

echo ">>> 4. Installing MySQL JDBC Connector..."
# Download the connector and extract only the .jar file into Tomcat/lib
wget -q "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_VER}.tar.gz" -P /tmp
tar -xzf /tmp/mysql-connector-java-${JDBC_VER}.tar.gz -C /tmp
cp /tmp/mysql-connector-java-${JDBC_VER}/mysql-connector-java-${JDBC_VER}.jar /opt/tomcat/lib/

echo ">>> 5. Setting Environment Variables..."
cat <<EOF > /opt/tomcat/bin/setenv.sh
export JAVA_HOME=${JAVA_HOME_PATH}
export CATALINA_PID="\$CATALINA_BASE/bin/tomcat.pid"
EOF

chmod +x /opt/tomcat/bin/*.sh

echo ">>> 6. Cleaning Up Temporary Files..."
rm -rf /tmp/apache-tomcat* /tmp/mysql-connector*

echo "----------------------------------------------------"
echo " SUCCESS: EFRIS ENVIRONMENT IS READY "
echo "----------------------------------------------------"
echo " MySQL DB:    ${DB_NAME}"
echo " DB User:     ${DB_USER}"
echo " JDBC Driver: Installed in /opt/tomcat/lib/"
echo " Tomcat Home: /opt/tomcat"
echo "----------------------------------------------------"
echo " To Start Service: sudo /opt/tomcat/bin/startup.sh"
echo " To Stop Service:  sudo /opt/tomcat/bin/shutdown.sh"
echo "----------------------------------------------------"

