# shell_scriptings
Sample Shell Scriptings 

### Disk space monitoring 💿💽
```
#!/bin/bash
# Set the threshold percentage.
threshold=50

# Email details
TO_address="your-email@abc.com
SUBJECT="*****Alert on Disk Utilization*****"
BODY=""

# Get the current disk usage percentage for the root partition
disk_usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ $disk_usage -gt $threshold ];then
   BODY+="DISK usage is at ${disk_usage}%\n"
fi

# Condition to send E-mail Notification
if [ -n "$BODY" ];then
   echo -e "$BODY" | mail -s "SUBJECT" $TO_address
fi

```
### Configure Mail in Ec2 instance
```
sudo apt-get install mailutils
```
### To setup Cron Job 
To trigger Email for every 5 mints use command crontab -e 
```
*/5 * * * * /path/to/resource_monitor.sh
```
