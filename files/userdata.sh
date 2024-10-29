#!/bin/bash

# Update /etc/hosts
sudo echo "127.0.0.1 $(hostname)" >> /etc/hosts

# Wait for the EBS volume to be attached
while [ ! -e /dev/xvdf ]; do
  sleep 1
done

# Format the attached EBS volume as ext4
sudo mkfs -t ext4 /dev/xvdf  

# Create a mount point
sudo mkdir -p /mnt/wordpress_data

# Mount the volume
sudo mount /dev/xvdf /mnt/wordpress_data  

# Add entry to fstab to mount on boot
echo '/dev/xvdf /mnt/wordpress_data ext4 defaults 0 0' | sudo tee -a /etc/fstab


# Update package index
sudo apt-get update -y

# Install MySQL client to connect to RDS
sudo apt-get install -y mysql-client

# Export MySQL endpoint as an environment variable (passed from Terraform)
export MYSQL_HOST="${aws_db_instance.wordpress_rds_likky.endpoint}"

# Connect to RDS and create the required database and user
mysql -h $MYSQL_HOST -P 3306 -u ${var.db_username} -p"${var.db_password}" <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER 'wordpressuser'@'%' IDENTIFIED BY 'Likhitha1234';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'%';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Install Apache 
sudo apt-get install -y apache2

# Start Apache service and enable it to start on boot
sudo systemctl start apache2
sudo systemctl enable apache2

# Download and extract the latest WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Move WordPress files to the Apache root directory
sudo cp -r wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configure WordPress by editing wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Update wp-config.php with database connection details
sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wordpressuser/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/Likhitha1234/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$MYSQL_HOST/" /var/www/html/wp-config.php

# Add secret keys to wp-config.php from the WordPress API
curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a /var/www/html/wp-config.php > /dev/null

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "WordPress installation is complete. Visit your EC2 public IP to complete the setup."
