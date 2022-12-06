# Automation_Project
installation of apache2 in ubuntu
The script in automation-v01 initiallychecks for apache2 present or not
If apache is present then it will check whether its started or not 
If apache is not started it will start
If the apache is not present it will install and starts the service.
after installation it will cehck or logs and zips it and places in tmp folder.
Finally contents are placed in the s3 bucket which we created.
