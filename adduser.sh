#!/bin/bash

##########################################################
# * adduser V 1.5                                        #
# * CentOS APMinstaller v.1.5 전용                        #
# * Created Date    : 2019/11/30                         #
# * Created by  : Joo Sung ( webmaster@apachezone.com )  # 
##########################################################

echo "

               [1] 사용자 계정, VHOST, DB, SSL 통합 추가하기.
               
               [2] 사용자 계정 개별 추가하기.  
               
               [3] VirtualHost 개별 추가하기.                 

               [4] Mysql 계정 개별 추가하기.                  

               [5] Let's Encrypt SSL 개별 추가하기.   
	       
"

echo -n "select Number:"
read Num

case "$Num" in


#사용자 계정, VHOST, DB, SSL 통합 추가하기.
1)
echo =======================================================
echo
echo  "< 계정 사용자 통합 추가하기>"
echo
echo  계정ID, 도메인, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "계정 ID 입력:"
         read id

echo -n "도메인 주소 입력:"
         read url

echo -n "서버 php 입력하세요 (56, 70, 71, 72, 73, 74 중 하나만 선택 입력) :"
         read php

echo -n "계정 패스워드 입력:"
         read pass

echo -n "
        계 정   : $id  
	패스워드 : $pass
	도메인  : $url
	php버전 : $php

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

#계정 ID 추가 
adduser $id

#패스 워드 추가 
echo "$pass" | passwd --stdin "$id"

#VHOST 추가하기
echo "<VirtualHost *:80>
DocumentRoot /home/$id/public_html
ServerName $url
ServerAlias www.$url
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:90$php"
</FilesMatch>
    ErrorLog logs/$url-error_log
    CustomLog logs/$url-access_log common
#SetEnvIFNoCase Referer $url link_allow 
#<FilesMatch \"\.(gif|jpg|jpeg|png|bmp)$\"> 
#  Order allow,deny 
#  allow from env=link_allow 
#  deny from all 
#</FilesMatch> 
</VirtualHost>" >> /etc/httpd/conf.d/$id.conf

#계정 폴더 퍼미션 변경
chmod 701 /home/$id

# Mysql 계정 추가하기 
echo "create database $id;
GRANT ALL PRIVILEGES ON $id.* TO $id@localhost IDENTIFIED by '$pass';" > ./tmp

echo "Mysql ROOT 패스워드를 입력하세요"

mysql -u root -p mysql < ./tmp

rm -f ./tmp

#SSL 추가 하기 
certbot --apache -d $url -d www.$url

#아파치 restart
service httpd restart
echo ""
echo ""
echo ""
echo "계정 및 VHOST, DB, SSL 추가 작업이 완료 되었습니다."
exit;;

 
#사용자 추가 하기 
2)
echo =======================================================
echo
echo  "< 계정 사용자 개별 추가하기>"
echo
echo  계정ID, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "사용자 계정 입력:"
         read id


echo -n "사용자 패스워드 입력:"
         read pass

echo -n "
        사용자 계정  : $id        
        사용자패스워드: $pass

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo""
echo "호스팅 사용자를 추가합니다."

#계정 ID 추가 
adduser $id
#패스 워드 추가 

echo "$pass" | passwd --stdin "$id"
echo "
 

"
echo "사용자 아이디와 패스워드 입니다"
echo ""
echo ""
echo "사용자 ID: $id" 

echo "패스워드 : $pass"

echo "사용자 추가 완료!"

exit;;

# 가상호스트 추가하기
3)

echo =======================================================
echo
echo  "< 가상 호스트 개별 추가하기 >"
echo
echo  계정 도메인, 계정ID, IP는 *:80 을 입력   
echo
echo =======================================================
echo 
echo -n "url 주소를 입력하세요 :"
         read url

echo -n "계정 ID를 입력 하세요 :"
         read id

echo -n "서버 IP 입력하세요 (*:80 을 입력) :"
         read ip

echo -n "서버 php 입력하세요 (56, 70, 71, 72, 73, 74 중 하나만 선택 입력) :"
         read php
echo -n "
       
          사용자 도메인 : $url
            게정 ID   : $id
            서버 IP   : $ip
	    php 버전  : $php   

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo "<VirtualHost $ip>
DocumentRoot /home/$id/public_html
ServerName $url
ServerAlias www.$url
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:90$php"
</FilesMatch>
    ErrorLog logs/$url-error_log
    CustomLog logs/$url-access_log common
#SetEnvIFNoCase Referer $url link_allow 
#<FilesMatch \"\.(gif|jpg|jpeg|png|bmp)$\"> 
#  Order allow,deny 
#  allow from env=link_allow 
#  deny from all 
#</FilesMatch> 
</VirtualHost>" >> /etc/httpd/conf.d/$id.conf

echo "가상 호스트 추가 완료!"

#계정 폴더 퍼미션 변경
chmod 701 /home/$id

#아파치 restart
service httpd restart

exit;;

# Mysql 계정 추가하기 
4)
echo =======================================================
echo
echo  "< Mysql 계정 개별 추가하기  >"
echo
echo  계정ID, MySql Password를 입력
echo
echo =======================================================
echo 
echo -n "Mysql 계정 :" 
         read id

echo -n "Mysql 패스워드 :"
         read pass
echo -n "
       
        사용자 ID : $id
        패스워드  : $pass

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

echo "create database $id;
GRANT ALL PRIVILEGES ON $id.* TO $id@localhost IDENTIFIED by '$pass';" > ./tmp

echo "
       Mysql 루트 패스워드를 입력하세요    
"

mysql -u root -p mysql < ./tmp

rm -f ./tmp


echo "DB 추가 완료!"
exit;; 



#SSL 추가 하기 
5)
echo =======================================================
echo
echo  "< Let's Encrypt SSL 개별 추가하기>"
echo
echo  계정ID, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "계정 ID :" 
         read id
echo -n "url 주소를 입력하세요 :"
         read url

echo -n "
        사용자 ID   : $id
        사용자 도메인 : $url
-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

certbot --apache -d $url -d www.$url

echo 
echo 
echo "Let's Encrypt SSL 추가 완료!"
echo 
exit;;*)

esac
