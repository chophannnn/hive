#!/bin/bash

echo "chophan" | sudo -S service ssh start
sudo service mysql start

initialized() {
	TABLE_NAME=$1
	
	RESULT=$(sudo mysql -h 172.18.0.3 -u hive -p"chophan" -e "USE metastore; SHOW TABLES LIKE '$TABLE_NAME';" | grep "$TABLE_NAME")
	
	if [ ! -z "$RESULT" ]; then
		return 0
	else
		return 1
	fi
}

initialized "VERSION"
INITIALIZED=$?

if [ "$INITIALIZED" -eq 0 ]; then
	$HIVE_HOME/bin/hive --service metastore &
	$HIVE_HOME/bin/hive --service hiveserver2 &
else
	$HIVE_HOME/bin/schematool -dbType mysql -initSchema
	$HIVE_HOME/bin/hive --service metastore &
	$HIVE_HOME/bin/hive --service hiveserver2 &
fi

tail -f /dev/null
