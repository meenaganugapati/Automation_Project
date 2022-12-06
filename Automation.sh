#!/bin/sh
s3_bucket=upgrad-meena
myname=meena
sudo apt update -y
dpkg --get-selections | grep apache
if [ $? -eq -1 ]; then
   echo " apache2 is already installed."
servstat=$(service apache2 status)

	if [[ $servstat == *"active (running)"* ]]; then
  		echo "process is running"
	else
  		sudo systemctl start apache2.service

		# checking if service statrted
		sudo service --status-all | grep apache2
		if [ $? -eq 0 ]; then
   			echo " apache2 service started successfully"
		else
   			echo "apache2 is not started"
		fi
	fi

else
   echo "apache2 is not installed, proceeding for installation"
sudo apt install apache2
sudo ufw app list
sudo ufw allow 'Apache'
servstat=$(service apache2 status)

	if [[ $servstat == *"active (running)"* ]]; then
  		echo "process is running"
	else
 	 sudo systemctl start apache2.service
	 sudo service --status-all | grep apache2
		if [ $? -eq 0 ]; then
   			echo " apache2 service started successfully"
		else
   			echo "apache2 is not started"
		fi
	fi

fi


#sudo ufw status

timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
sudo chmod 740 *.log
sudo tar -czf ${myname}-httpd-logs-${timestamp}.tar *.log
sudo mv  ${myname}-httpd-logs-${timestamp}.tar /tmp

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar



