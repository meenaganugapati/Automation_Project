#!/bin/sh
s3_bucket=upgrad-meena
myname=meena
sudo apt update -y
dpkg --get-selections | grep apache
if [ $? -eq 0 ]; then
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


#task 3 starts here
sudo chmod u+rwx /var/www/html/
sudo chmod u+rwx /tmp/

file=/var/www/html/inventory.html
tarfile="$(ls  /tmp/meena*.tar | sort -V | tail -n1)"
#echo "tarfile name "$tarfile
tarfilepath=$tarfile
#echo $tarfilepath
Size="$(du -b "$tarfilepath" | cut -f 1) KB"
LogType=httpd-logs
TimeCreated=$(ls  -l "$tarfilepath"| grep -oP '[\d]+-[\d]+')
Type=tar

if [ -e "$file" ]; then
    echo "File exists"
    sudo tee -a $file > /dev/null <<EOT
echo "<tr>"
echo "<th><col width="100"><font color="000000">$LogType</font></th>"
echo "<th><col width="100"><font color="000000">$TimeCreated</font></th>"
echo "<th><col width="100"><font color="000000">$Type</font></th>"
echo "<th><col width="100"><font color="000000">$Size</font></th>"
echo "</tr>"
EOT
else
      sudo touch $file

sudo chmod ug+rwx $file
    echo "File doesnt exists so creating one"
    sudo tee -a $file > /dev/null <<EOT

echo "<html>"
echo "<body>"
echo "<tr>"
echo "<th><col width="100"><font color="000000">Log Type</font></th>"
echo "<th><col width="100"><font color="000000">Time Created</font></th>"
echo "<th><col width="100"><font color="000000">Type</font></th>"
echo "<th><col width="100"><font color="000000">size</font></th>"
echo "</tr>"
echo "<tr>"
echo "<th><col width="100"><font color="000000">$LogType</font></th>"
echo "<th><col width="100"><font color="000000">$TimeCreated</font></th>"
echo "<th><col width="100"><font color="000000">$Type</font></th>"
echo "<th><col width="100"><font color="000000">$Size</font></th>"
echo "</tr>"

echo "</body>"
echo "</html>"
EOT

fi

#cron lgic
cronpath=/etc/cron.d
sudo chmod ug+rwx $cronpath
cronfile="$cronpath/automation"
echo "path $cronfile"
if [ -e "$cronfile" ]; then
    echo "Cron File exists"
else
    echo "cron File doesnt exists so creating one"
    sudo touch $cronfile
    sudo tee -a $cronfile > /dev/null <<EOT
    1 * * * * /home/ubuntu/meena/automation2.sh
EOT
fi
