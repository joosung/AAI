#!/bin/bash

systemctl start clamd.service 
systemctl start clamd-scan.service 

clamscan -r /home --move=/virus

systemctl stop clamd.service 
systemctl stop clamd-scan.service 

sh /root/AAI/restart.sh