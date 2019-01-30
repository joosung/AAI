# AAI V.0.3.7
APM AUTO INSTALL V.0.3.7 사용 설명서

1. SSH와 SFTP 는 필히 root 권한으로 접속 합니다.

2. APMAUTOINSTALL V.0.3.7 압축 파일을 다운로드 받으시고 압축을 해제 후 APM 폴더를 자신의 서버 /root 폴더에 업로드한다.

3. Shell(터미널)에서 APM 폴더내의 APMinstaller.sh 파일의 퍼미션을 chmod 700 APMinstaller.sh 로 해당 파일의 퍼미션을 700 으로 수정한다.

4. ./APMinstaller.sh 입력후 엔터를 치고 설치를 진행 하시면 됩니다.

5. 작업이 완료후 로컬 아이피 로 이동 하시면 Welcome 페이지가 출력되면 모든 작업이 무사히 완료된 것입니다.

6. 설치 끝에 마리아디비 안전 설치를 진행 하시고 마리아db 패스워드와 기타 설정을 끝내시기 바랍니다.

7. phpMyAdmin 접속 경로는 http://ip/phpMyAdmin 또는 http://localhost/phpMyAdmin 으로 접속 하시면 됩니다.

8. 계정 생성은 adduser.sh 파일을 셀에서 ./adduser.sh 를 실행 하시면 안내에 따라 번호를 입력후 따라 하시면 사용자 계정, 가상호스트, db, ssl 설치 및 생성이 가능 합니다.

9. 스푸핑 에 관련된 메일을 받고 싶을땐 /etc/sysconfig/arpwatch 파일을 열어서 아래와 같이 수정 하세요.
   OPTIonS="-u pcap -e '메일주소' -s '보내는이(Arpwatch)' -n 'ㅣ자신의IP/24'"

10. 설지 작업이 모두 끝나면 ./chkrootkit 그리고 clamscan -r /home --move=/virus 를 각각 실행해서 바이러스와 멀웨어 등이 없는지 확인 합니다. 있다면 삭제 해 줍니다.

11. /etc/cron.daily/backup 파일을 에디터로 열고 '패스워드' 를 찾아서 DB 루트 패스워드로 교체 합니다.

12. Varnish Cache 플러그인 설치를 Y/N 으로 선택 추가 할 수 있도록 했습니다.


그외 소소한(?) 튜닝이나 설정은 구글 검색을 또는 아파치존 QnA 를 통하여 질문 하시면서 자신이 사용하기 좋은 환경을 만들어 가시면 됩니다.

AAI 설치 및 계정생성과 삭제 방법을 아파치존에서 동영상으로 안내 합니다.

https://apachezone.com

<pre>
APM 설치 버전은 아래와 같습니다.

httpd 2.4.38
php 7.2.14
mariadb 10.3.12
ionCube PHP Loader 10.2.7
Zend OPcache 7.2.13
Xdebug 2.6.1
Let's Encrypt 0.27.1
phpMyAdmin 4.8.4
chkrootkit 0.52
clamav 101.1-1
arpwatch 2.1a15-36
fail2ban 0.9.7-1
mod_evasive 1.10.1-22
mod_security 2.9.2-1
mod_security_crs 2.2.9-1
mod_qos 11.5-1
memcache 3.0.9-0.9
memcached 1.4.15-10
mod_expires 설정
GeoIP 1.1.1
사용지 계정 백업 스크립트 1.0.2
사용자 계정 생성 스크립트 1.0.2
사용자 계정 삭제 스크립트 1.0.2 등...... 그외 필요한 라이브러리도 같이 설치가 됩니다. 
</pre>


