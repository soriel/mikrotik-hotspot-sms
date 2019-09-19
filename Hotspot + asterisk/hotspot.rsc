/interface bridge
add fast-forward=no name=bridge1
add comment=Hotspot fast-forward=no name=bridge2
add fast-forward=no name=lo
/interface wireless
set [ find default-name=wlan2 ] ssid=MikroTik
/interface list
add name=WAN
add name=local
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk eap-methods="" management-protection=\
    allowed mode=dynamic-keys name=guest supplicant-identity="" \
    wpa2-pre-shared-key=PassWord123
/interface wireless
set [ find default-name=wlan1 ] adaptive-noise-immunity=ap-and-client-mode \
    band=2ghz-onlyn country=russia3 default-forwarding=no disabled=no \
    distance=indoors hw-protection-mode=cts-to-self max-station-count=30 \
    mode=ap-bridge preamble-mode=long radio-name=Mikrotik-Training.ru-Guest \
    security-profile=guest ssid=Mikrotik-Training.ru-Guest
/ip hotspot profile
set [ find default=yes ] html-directory=flash/hotspot
add hotspot-address=10.5.50.1 html-directory=flash/hotspot name=hsprof1 \
    use-radius=yes
/ip hotspot user profile
set [ find default=yes ] on-login=":local nas [/system identity get name];\r\
    \n:local today [/system clock get date];\r\
    \n:local time1 [/system clock get time ];\r\
    \n:local ipuser [/ip hotspot active get [find user=\$user] address];\r\
    \n:local usermac [/ip hotspot active get [find user=\$user] mac-address]\r\
    \n:put \$today\r\
    \n:put \$time1\r\
    \n:local hour [:pick \$time1 0 2]; \r\
    \n:local min [:pick \$time1 3 5]; \r\
    \n:local sec [:pick \$time1 6 8];\r\
    \n:set \$time1 [:put ({hour} . {min} . {sec})] \r\
    \n:local mac1 [:pick \$usermac 0 2];\r\
    \n:local mac2 [:pick \$usermac 3 5];\r\
    \n:local mac3 [:pick \$usermac 6 8];\r\
    \n:local mac4 [:pick \$usermac 9 11];\r\
    \n:local mac5 [:pick \$usermac 12 14];\r\
    \n:local mac6 [:pick \$usermac 15 17];\r\
    \n:set \$usermac [:put ({mac1} . {mac2} . {mac3} . {mac4} . {mac5} . {mac6\
    })]\r\
    \n:put \$time1\r\
    \n/ip firewall address-list add list=\$today address=\"log-in.\$time1.\$us\
    er.\$usermac.\$ipuser\"\r\
    \n\r\
    \ndo {/tool e-mail send to=\"email@gmail.com\" subject=\"Login number:\
    \_\$user on \$nas\" body=\"Login number: \$user mac-address: \$usermac tim\
    e: \$time1 ip-address: \$ipuser\"} on-error={};" on-logout=":local nas [/s\
    ystem identity get name];\r\
    \n:local today [/system clock get date];\r\
    \n:local time1 [/system clock get time ];\r\
    \n:put \$today\r\
    \n:put \$time1\r\
    \n:local hour [:pick \$time1 0 2]; \r\
    \n:local min [:pick \$time1 3 5];\r\
    \n:local sec [:pick \$time1 6 8];\r\
    \n:set \$time1 [:put ({hour} . {min} . {sec})] \r\
    \n:put \$time1\r\
    \n/ip firewall address-list add list=\$today address=\"log-out.\$time1.\$u\
    ser\"\r\
    \n/tool e-mail send to=\"email@gmail.com\" subject=\"Logout number: \$\
    user on \$nas\" body=\"Logout number: \$user time: \$time1\""
/ip pool
add name=hs-pool-9 ranges=10.5.50.2-10.5.50.254
/ip dhcp-server
add address-pool=hs-pool-9 disabled=no interface=bridge2 lease-time=1h name=\
    dhcp1
/ip hotspot
add address-pool=hs-pool-9 disabled=no interface=bridge2 name=hotspot1 \
    profile=hsprof1
/system logging action
add name=hotspot target=memory
/tool user-manager customer
set admin access=\
    own-routers,own-users,own-profiles,own-limits,config-payment-gw
/tool user-manager profile
add name=hotspot name-for-users="" override-shared-users=off owner=admin \
    price=0 starts-at=logon validity=0s
/tool user-manager profile limitation
add address-list="" download-limit=0B group-name="" ip-pool="" name=unlimited \
    owner=admin transfer-limit=0B upload-limit=0B uptime-limit=0s
/interface bridge port
add bridge=bridge2 interface=wlan1
/ip neighbor discovery-settings
set discover-interface-list=WAN
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=local
add interface=bridge1 list=local
/ip address
add address=10.5.50.1/24 comment="hotspot network" interface=bridge2 network=\
    10.5.50.0
add address=10.11.11.1 interface=lo network=10.11.11.1
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1
/ip dhcp-server network
add address=10.5.50.0/24 comment="hotspot network" gateway=10.5.50.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
/ip firewall address-list
add address=log-in.165846.9067634683.60F1894825C4.10.5.50.254 list=\
    mar/14/2018
add address=log-out.170409.9067634683 list=mar/14/2018
add address=log-in.170543.9067634683.60F1894825C4.10.5.50.254 list=\
    mar/14/2018
/ip firewall filter
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=accept chain=forward comment=Established/related connection-state=\
    established,related
add action=accept chain=input connection-state=established,related
add action=drop chain=input comment=Invalid connection-state=invalid \
    in-interface-list=WAN
add action=drop chain=forward connection-state=invalid in-interface-list=WAN
add action=accept chain=input comment=Icmp in-interface-list=WAN protocol=\
    icmp
add action=accept chain=input comment=Winbox dst-port=8291 in-interface-list=\
    WAN protocol=tcp
add action=accept chain=input comment=Webfig dst-port=80 in-interface-list=\
    WAN protocol=tcp
add action=drop chain=input comment=Drop in-interface-list=WAN
add action=drop chain=forward in-interface-list=WAN
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    out-interface-list=WAN src-address=10.5.50.0/24
add action=masquerade chain=srcnat out-interface-list=WAN
/ip hotspot user
add name=admin
add name=9067634683 password=1879
/radius
add accounting-backup=yes address=10.11.11.1 secret=PassWord123! service=\
    hotspot src-address=10.11.11.1
/system clock
set time-zone-name=Europe/Moscow
/system identity
set name=Mikrotik-Training.ru-Guest
/system logging
add action=hotspot topics=hotspot,debug,info,!account
/system scheduler
add interval=1d name=backup on-event="/system script run backup " policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=mar/14/2018 start-time=13:41:01
add interval=30s name=hotspot on-event="/system script run hotspot" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=mar/14/2018 start-time=13:59:23
/system script
add name=hotspot owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    Search number in log hotspot\
    \n\
    \n:foreach line in=[/log find buffer=hotspot message~\"login failed\"] do=\
    {\
    \n :do {:local content [/log get \$line message];\
    \n  :put \$content;\
    \n  :local pos1 [:find \$content \" (\" 0];\
    \n  :put \$pos1;\
    \n  :if (\$pos1 != \" \") do={ \
    \n   :local uname \"\"; \
    \n   :local uname7 \"\";\
    \n   :local uname8 \"\";\
    \n   :local uname9 \"\";\
    \n   :local phone \"\"; \
    \n   :if ([:pick \$content (\$pos1-11)] = \"8\") do={ \
    \n    :set uname [:pick \$content (\$pos1-10) (\$pos1-0)];  \
    \n    :put \$uname;\
    \n    :set uname7 [:put (\"7\" . {\$uname})]\
    \n    :set uname8 [:put (\"8\" . {\$uname})]\
    \n    :put \$uname7\
    \n    :put \$uname8\
    \n    #Password generation \
    \n    :local date [/system clock get time]; \
    \n    :local hour [:pick \$date 0 2]; \
    \n    :local min [:pick \$date 3 5]; \
    \n    :local sec [:pick \$date 6 8]; \
    \n    :local usernumber [:pick \$content (\$pos1-7) (\$pos1-5)];\
    \n    :put \$usernumber;\
    \n    :global pass 27394; \
    \n    :set pass (\$hour * \$min * \$sec - \$usernumber); \
    \n    :if (\$pass = 0) do={ \
    \n     :set pass 6524;\
    \n     }\
    \n    :put \$pass;\
    \n    #Add user to hotspot / user-manager \
    \n\
    \n    do {/ip hotspot user add name=\$uname} on-error={};\
    \n    do {/ip hotspot user set password=\$pass numbers=[find name=\$uname]\
    } on-error={};\
    \n    do {/tool user-manager user add username=\$uname password=\$pass cus\
    tomer=admin copy-from=test disabled=no phone=\$uname;} on-error={};\
    \n    do {/tool user-manager user set password=\$pass number=[find usernam\
    e=\$uname]} on-error={}; \
    \n    ##SMS.ru\
    \n    #do {/tool fetch url=\"http://sms.ru/sms/send\?api_id=!!!!!!!!!!!!!!\
    !!!!!!!!!!!!!!!!!!!!&to=\$uname&text=\$pass\"} on-error={}; \
    \n    do {/tool fetch url=\"https://gate.smsaero.ru/send/\\\?user=info@ast\"https://gate.smsaero.ru/send/\\\?user=login&password=UID&to=\$uname7&text=password+\
    \$pass&from=name\\"} on-error={};\
    \n    do {/tool sms send usb1 phone-number=\"\$uname7\" message=\"login \$\
    uname password \$pass\"} on-error={};\
    \n    #Email\
    \n    do {/tool e-mail send to=\"email@gmail.com\" subject=\"Login \$u\
    name password \$pass\" body=\"Login \$uname password \$pass\"} on-error={}\
    ;    \
    \n    }\
    \n   :if ([:pick \$content (\$pos1-10)] = \"9\") do={ \
    \n    :set uname [:pick \$content (\$pos1-10) (\$pos1-0)];  \
    \n    :put \$uname;\
    \n    :set uname7 [:put (\"7\" . {\$uname})]\
    \n    :set uname8 [:put (\"8\" . {\$uname})]\
    \n    :put \$uname7\
    \n    :put \$uname8\
    \n    #Password generation \
    \n    :local date [/system clock get time]; \
    \n    :local hour [:pick \$date 0 2]; \
    \n    :local min [:pick \$date 3 5]; \
    \n    :local sec [:pick \$date 6 8]; \
    \n    :local usernumber [:pick \$content (\$pos1-7) (\$pos1-5)];\
    \n    :put \$usernumber;\
    \n    :global pass 27394; \
    \n    :set pass (\$hour * \$min * \$sec - \$usernumber); \
    \n    :if (\$pass = 0) do={ \
    \n     :set pass 6524;\
    \n     }\
    \n    :put \$pass;\
    \n    #Add user to hotspot / user-manager \
    \n\
    \n    do {/ip hotspot user add name=\$uname} on-error={};\
    \n    do {/ip hotspot user set password=\$pass numbers=[find name=\$uname]\
    } on-error={};\
    \n    do {/tool user-manager user add username=\$uname password=\$pass cus\
    tomer=admin copy-from=test disabled=no phone=\$uname7;} on-error={};\
    \n    do {/tool user-manager user set password=\$pass number=[find usernam\
    e=\$uname]} on-error={}; \
    \n    ##SMS.ru\
    \n    #do {/tool fetch url=\"http://sms.ru/sms/send\?api_id=!!!!!!!!!!!!!!\
    !!!!!!!!!!!!!!!!!!!!&to=\$uname&text=\$pass\"} on-error={}; \
    \n    do {/tool fetch url=\"https://gate.smsaero.ru/send/\\\?user=login&password=UID&to=\$uname7&text=password+\
    \$pass&from=name\"} on-error={};\
    \n    do {/tool sms send usb1 phone-number=\"\$uname7\" message=\"login \$\
    uname password \$pass\"} on-error={};\
    \n    #Email\
    \n    do {/tool e-mail send to=\"email@gmail.com\" subject=\"Login \$u\
    name password \$pass\" body=\"Login \$uname password \$pass\"} on-error={}\
    ;    \
    \n    }\
    \n\
    \n   :if ([:pick \$content (\$pos1-11)] = \"7\") do={ \
    \n    :set uname [:pick \$content (\$pos1-10) (\$pos1-0)];  \
    \n    :put \$uname;\
    \n    :set uname7 [:put (\"7\" . {\$uname})]\
    \n    :set uname8 [:put (\"8\" . {\$uname})]\
    \n    :put \$uname7\
    \n    :put \$uname8\
    \n    #Password generation \
    \n    :local date [/system clock get time] \
    \n    :local hour [:pick \$date 0 2] \
    \n    :local min [:pick \$date 3 5] \
    \n    :local sec [:pick \$date 6 8] \
    \n    :local usernumber [:pick \$content (\$pos1-7) (\$pos1-4)];\
    \n    :global pass 27394 \
    \n    :set pass (\$hour * \$min * \$sec - \$usernumber) \
    \n    :if (\$pass = 0) do={ \
    \n     :set pass 6524 \
    \n     } \
    \n    :put \$pass\
    \n    #Add user to hotspot / user-manager \
    \n\
    \n    do {/ip hotspot user add name=\$uname} on-error={};\
    \n    do {/ip hotspot user set password=\$pass numbers=[find name=\$uname]\
    } on-error={};\
    \n    do {/tool user-manager user add username=\$uname password=\$pass cus\
    tomer=admin copy-from=test disabled=no phone=\$uname;} on-error={};\
    \n    do {/tool user-manager user set password=\$pass number=[find usernam\
    e=\$uname]} on-error={};\
    \n    ##SMS \
    \n    #do {/tool fetch url=\"http://sms.ru/sms/send\?api_id=!!!!!!!!!!!!!!\
    !!!!!!!!!!!!!!!!!!!!&to=\$uname&text=\$pass\"} on-error={}; \
    \n    do {/tool sms send usb1 phone-number=\"\$uname7\" message=\"login \$\
    uname password \$pass\"} on-error={};\
    \n    do {/tool fetch url=\""https://gate.smsaero.ru/send/\\\?user=login&password=UID&to=\$uname7&text=password+\
    \$pass&from=name\"} on-error={};\
    \n    #Email\
    \n    do {/tool e-mail send to=\"email@gmail.com\" subject=\"Login \$u\
    name password \$pass\" body=\"Login \$uname password \$pass\"} on-error={}\
    ;  \
    \n\
    \n    }\
    \n  }\
    \n }\
    \n}\
    \n\
    \n\
    \n\
    \n# Clear hostpot log\
    \n\
    \n/system logging action set hotspot memory-lines=1;\
    \n/system logging action set hotspot memory-lines=1000;"
add name=backup owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    export compact file=auto_backup_user-manager;\r\
    \n/system backup save name=auto_backup_user-manager.backup;\r\
    \n:if ( [ /file find name=auto_backup_user-manager.umb ] != \"\" ) do={\r\
    \n/file remove auto_backup_user-manager.umb;\r\
    \n};\r\
    \n/tool user-manager database save name=auto_backup_user-manager;\r\
    \n/delay delay-time=60;\r\
    \n\r\
    \n\r\
    \n/tool e-mail send to=\"email@gmail.com\" subject=(\"Export Script Us\
    er Manager \".[ /system clock get date ].\" \".[ /system clock get time ])\
    \_file=auto_backup_user-manager.rsc;\r\
    \n/delay delay-time=60;\r\
    \n/tool e-mail send to=\"email@gmail.com\" subject=(\"Backup Config Us\
    er Manager \".[ /system clock get date ].\" \".[ /system clock get time ])\
    \_file=auto_backup_user-manager.backup;\r\
    \n/delay delay-time=60;\r\
    \n/tool e-mail send to=\"email@gmail.com\" subject=(\"Backup Database \
    User Manager \".[ /system clock get date ].\" \".[ /system clock get time \
    ]) file=auto_backup_user-manager.umb;\r\
    \n/delay delay-time=60;"
/tool e-mail
set address=smtp.gmail.com from=email@gmail.com password=\
    PassWord port=587 start-tls=yes user=email@gmail.com
/tool mac-server
set allowed-interface-list=local
/tool mac-server mac-winbox
set allowed-interface-list=local
/tool user-manager database
set db-path=flash/user-manager
/tool user-manager profile profile-limitation
add from-time=0s limitation=unlimited profile=hotspot till-time=23h59m59s \
    weekdays=sunday,monday,tuesday,wednesday,thursday,friday,saturday
/tool user-manager router
add coa-port=1700 customer=admin disabled=no ip-address=10.11.11.1 log=\
    auth-fail name=Mikrotik-Training.ru-Guest shared-secret=PassWord123! \
    use-coa=no
/tool user-manager user
add customer=admin disabled=no password=test121212313123132312 shared-users=1 \
    username=test wireless-enc-algo=none wireless-enc-key="" wireless-psk=""
add customer=admin disabled=no password=1879 phone=79067634683 shared-users=1 \
    username=9011111111 wireless-enc-algo=none wireless-enc-key="" \
    wireless-psk=""
