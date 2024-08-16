#!/bin/bash

echo "chophan" | sudo -S service mysql start

sudo mysql -e "
  ALTER USER 'root'@'localhost' IDENTIFIED WITH MYSQL_NATIVE_PASSWORD BY 'chophan';

  CREATE USER 'hive'@'172.18.0.3' IDENTIFIED BY 'chophan';
  GRANT ALL PRIVILEGES ON *.* TO 'hive'@'172.18.0.3' WITH GRANT OPTION;

  CREATE DATABASE metastore;
"
