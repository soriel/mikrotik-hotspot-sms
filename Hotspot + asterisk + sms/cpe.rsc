/interface bridge add admin-mac=C1:2D:E1:F9:11:11 auto-mac=no comment=Hotspot fast-forward=no name=bridge2
/ip hotspot profile set [ find default=yes ] hotspot-address=10.5.50.1 html-directory=flash/hotspot use-radius=yes
/ip hotspot profile add hotspot-address=10.5.50.1 html-directory=flash/hotspot http-cookie-lifetime=1h login-by=cookie,http-chap,http-pap,mac-cookie name=hsprof2 use-radius=yes
/ip hotspot user profile set [ find default=yes ] on-login=":local nas [/system identity get name];\r\
    \n\r\
    \n:local today [/system clock get date];\r\
    \n\r\
    \n:local time1 [/system clock get time ];\r\
    \n\r\
    \n:local ipuser [/ip hotspot active get [find user=\$user] address];\r\
    \n\r\
    \n:local usermac [/ip hotspot active get [find user=\$user] mac-address]\r\
    \n\r\
    \n:put \$today\r\
    \n\r\
    \n:put \$time1\r\
    \n\r\
    \n:local hour [:pick \$time1 0 2]; \r\
    \n\r\
    \n:local min [:pick \$time1 3 5]; \r\
    \n\r\
    \n:local sec [:pick \$time1 6 8];\r\
    \n\r\
    \n:set \$time1 [:put ({hour} . {min} . {sec})] \r\
    \n\r\
    \n:local mac1 [:pick \$usermac 0 2];\r\
    \n\r\
    \n:local mac2 [:pick \$usermac 3 5];\r\
    \n\r\
    \n:local mac3 [:pick \$usermac 6 8];\r\
    \n\r\
    \n:local mac4 [:pick \$usermac 9 11];\r\
    \n\r\
    \n:local mac5 [:pick \$usermac 12 14];\r\
    \n\r\
    \n:local mac6 [:pick \$usermac 15 17];\r\
    \n\r\
    \n:set \$usermac [:put ({mac1} . {mac2} . {mac3} . {mac4} . {mac5} . {mac6})]\r\
    \n\r\
    \n:put \$time1\r\
    \n\r\
    \n/ip firewall address-list add list=\$today address=\"log-in.\$time1.\$user.\$usermac.\$ipuser\"\r\
    \n\r\
    \n\r\
    \n\r\
    \n#do {/tool e-mail send to=\"@gmail.com\" subject=\"Login number: \$user on \$nas\" body=\"Login number: \$user mac-address: \$usermac time: \$time1 ip-address: \$ipuser\"} on-error={};\r\
    \n" on-logout=":local nas [/system identity get name];\r\
    \n\r\
    \n:local today [/system clock get date];\r\
    \n\r\
    \n:local time1 [/system clock get time ];\r\
    \n\r\
    \n:put \$today\r\
    \n\r\
    \n:put \$time1\r\
    \n\r\
    \n:local hour [:pick \$time1 0 2]; \r\
    \n\r\
    \n:local min [:pick \$time1 3 5];\r\
    \n\r\
    \n:local sec [:pick \$time1 6 8];\r\
    \n\r\
    \n:set \$time1 [:put ({hour} . {min} . {sec})] \r\
    \n\r\
    \n:put \$time1\r\
    \n\r\
    \n/ip firewall address-list add list=\$today address=\"log-out.\$time1.\$user\"\r\
    \n\r\
    \n#/tool e-mail send to=\"@gmail.com\" subject=\"Logout number: \$user on \$nas\" body=\"Logout number: \$user time: \$time1\""
/ip pool add name=hs-pool-5 ranges=10.5.50.2-10.5.50.254
/ip dhcp-server add address-pool=hs-pool-5 disabled=no interface=bridge2 lease-time=1h name=dhcp1
/interface bridge port add bridge=bridge2 interface=wlan1
/ip address add address=10.5.50.1/24 comment="hotspot network" interface=bridge2 network=10.5.54.0
/ip dhcp-server network add address=10.5.50.0/24 comment="hotspot network" gateway=10.5.50.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1
/radius add address=10.1.1.2 secret=PassWord123 service=hotspot src-address=10.1.1.1
/radius incoming set accept=yes
