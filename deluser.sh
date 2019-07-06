#!/bin/bash

##########################################################
# * deluser V 1.1                                        #
# * APMinstaller v.1.0  전용                              #
# * Created Date    : 2019/6/30                          #
# * Created by  : Joo Sung ( webmaster@apachezone.com )  # 
##########################################################

echo "

               [1] 사용자 계정, VHOST, DB, SSL 통합 삭제하기.
	       
	       [2] 사용자 계정 개별 삭제하기.
               
               [3] VirtualHost 개별 삭제하기.                 

               [4] Mysql 계정 개별 삭제하기.                  

               [5] Let's Encrypt SSL 개별 삭제하기.   
	       
"

echo -n "select Number:"
read Num

case "$Num" in

#사용자 계정, 가상 호스트, DB 통합 삭제하기.
1)
echo =======================================================
echo
echo  "< 계정 사용자 통합 삭제하기>"
echo
echo  계정 사용자 ID 와 도메인을 입력       
echo
echo =======================================================
echo 
echo -n "사용자 ID 입력:"
         read id
echo -n "도메인을 입력하세요 :"
         read url
echo -n "
        사용자 계정: $id
	사용자 도메인 : $url
        
-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo""
echo "호스팅 계정 및 DB, VHOST, SSL 등 을 삭제 합니다."

#계정삭제
userdel -r $id

#VHOST삭제
rm -rf /etc/httpd/conf.d/$id.conf
rm -rf /etc/httpd/conf.d/$id-le-ssl.conf

#DB삭제
echo "drop database $id;
DROP USER $id@localhost;
flush privileges;" > ./tmp

echo "
       Mysql 루트 패스워드를 입력하세요    
"

mysql -u root -p mysql < ./tmp
rm -f ./tmp

#SSL삭제
certbot delete --cert-name $url

#아파치 restart
service httpd restart

echo 
echo 
echo "삭제가 완료 되었습니다."
exit;;


#사용자 삭제 하기 
2)
echo =======================================================
echo
echo  "< 계정 사용자 개별 삭제하기>"
echo
echo  계정 사용자 ID 를 입력       
echo
echo =======================================================
echo 
echo -n "사용자 ID 입력:"
         read id

echo -n "
        사용자 계정: $id
        
-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo""
echo "호스팅 사용자를 삭제 합니다."

#계정삭제
userdel -r $id

echo "사용자 아이디 입니다"
echo ""
echo ""
echo "사용자 ID: $id" 

echo "사용자 삭제 완료!"
exit;;

# 가상호스트 추가하기
3)

echo =======================================================
echo
echo  "< 가상 호스트 개별 삭제하기 >"
echo
echo  계정 도메인, 계정ID 를 입력   
echo
echo =======================================================
echo 
echo -n "url 주소를 입력하세요 :"
         read url
echo -n "계정 ID를 입력 하세요 :"
         read id
echo -n "
       
        사용자 도메인 : $url
            게정 ID   : $id

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

rm -rf /etc/httpd/conf.d/$id.conf
rm -rf /etc/httpd/conf.d/$id-le-ssl.conf

echo "가상 호스트 삭제 완료!"

#아파치 restart
service httpd restart

exit;;

# Myslq 계정 추가하기 
4)
echo =======================================================
echo
echo  "< Myslq 계정 개별 삭제하기  >"
echo
echo  계정ID, MySql Password를 입력
echo
echo =======================================================
echo 
echo -n "Mysql 계정 :" 
         read id
echo -n "
       
        사용자 ID : $id

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

echo "drop database $id;
DROP USER $id@localhost;
flush privileges;" > ./tmp

echo "
       Mysql 루트 패스워드를 입력하세요    
"

mysql -u root -p mysql < ./tmp

rm -f ./tmp


echo "DB 삭제 완료!"
exit;; 

#SSL 삭제가 하기 
5)
echo =======================================================
echo
echo  "< Let's Encrypt SSL 개별 삭제하기>"
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
        사용자 ID : $id
        사용자 도메인 : $url
-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

#SSL삭제
certbot delete --cert-name $url


echo 
echo 
echo "Let's Encrypt SSL 삭제 완료!"
echo 
exit;;*)

esac
