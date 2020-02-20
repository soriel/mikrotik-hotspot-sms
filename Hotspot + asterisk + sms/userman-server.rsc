/system logging action add name=userman target=memory
/tool user-manager customer set admin access=own-routers,own-users,own-profiles,own-limits,config-payment-gw password=PassWord
/tool user-manager profile add name=guest name-for-users="" override-shared-users=5 owner=admin price=0 starts-at=logon validity=0s
/tool user-manager profile limitation add address-list="" download-limit=0B group-name="" ip-pool="" ip-pool6="" name=guest owner=admin rate-limit-burst-rx=5242880B rate-limit-burst-time-rx=16s rate-limit-burst-time-tx=16s rate-limit-burst-treshold-rx=2097152B rate-limit-burst-treshold-tx=2097152B rate-limit-burst-tx=5242880B rate-limit-min-rx=2097152B rate-limit-min-tx=2097152B rate-limit-priority=8 rate-limit-rx=2097152B rate-limit-tx=2097152B transfer-limit=0B upload-limit=0B uptime-limit=0s
/system scheduler add interval=10s name=schedule1 on-event="/system script run userman" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=feb/20/2020 start-time=09:28:22
/system script add dont-require-permissions=no name=userman owner=admin77 policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":foreach line in=[/log find buffer=userman message~\"Reply-Message = \\\"user \"] do={\
    \n\
    \n :do {:local content [/log get \$line message];\
    \n\
    \n  :put \$content;\
    \n\
    \n  :local pos1 [:find \$content \"<\" 0];\
    \n\
    \n  :put \$pos1;\
    \n\
    \n  :if (\$pos1 != \" \") do={ \
    \n\
    \n   :local uname \"\"; \
    \n\
    \n   :local uname7 \"\";\
    \n\
    \n   :local uname8 \"\";\
    \n\
    \n   :local uname9 \"\";\
    \n\
    \n   :local unameD \"\";\
    \n\
    \n   :local phone \"\"; \
    \n\
    \n   :if ([:pick \$content (\$pos1+1)] = \"9\") do={ \
    \n\
    \n    :set uname [:pick \$content (\$pos1+1) (\$pos1+11)];  \
    \n\
    \n    :put \$uname;\
    \n\
    \n    :set uname7 [:put (\"7\" . {\$uname})]\
    \n\
    \n    :set uname8 [:put (\"8\" . {\$uname})]\
    \n\
    \n    :set unameD [:pick \$content (\$pos1+11)];\
    \n\
    \n    :put \$unameD \
    \n\
    \n    #SendTest\
    \n\
    \n\
    \n\
    \n    :local sendtest yes;\
    \n\
    \n    :foreach i in=[/ip fi ad print as-value where list=sendsms] do={\
    \n\
    \n    :if ((\$i->\"address\")=\$uname7) do={\
    \n\
    \n    :set \$sendtest no;\
    \n\
    \n     }\
    \n\
    \n    }\
    \n\
    \n     #Password generation \
    \n\
    \n\
    \n\
    \n    :local date [/system clock get time]; \
    \n\
    \n\
    \n\
    \n    :local hour [:pick \$date 0 2]; \
    \n\
    \n\
    \n\
    \n    :local min [:pick \$date 3 5]; \
    \n\
    \n\
    \n\
    \n    :local sec [:pick \$date 6 8]; \
    \n\
    \n\
    \n\
    \n    :local usernumber [:pick \$content (\$pos1+5) (\$pos1+7)];\
    \n\
    \n\
    \n\
    \n    :put \$usernumber;\
    \n\
    \n\
    \n\
    \n    :global pass 27394; \
    \n\
    \n\
    \n\
    \n    :set pass (\$hour * \$min * \$sec - \$usernumber); \
    \n\
    \n\
    \n\
    \n    :if (\$pass = 0) do={ \
    \n\
    \n\
    \n\
    \n     :set pass 6524;\
    \n\
    \n\
    \n\
    \n     }\
    \n\
    \n\
    \n\
    \n    :put \$pass;\
    \n\
    \n\
    \n\
    \n    :local changepassword [:do {/tool user-manager user set password=\$pass number=[find username=\$uname]} on-error={}];\
    \n\
    \n    :local timeoutsendsms [:do {/ip firewall address-list add list=\"sendsms\" address=\"\$uname7\" timeout=\"3m\"} on-error={}];\
    \n\
    \n    :local putpasschange [:put \"PAASScange\"]\
    \n\
    \n    :local putpassnew [:put \"Pass New\"]\
    \n\
    \n    :local sendsms [/tool fetch url=\"https://gate.smsaero.ru/send/\\\?user=EMAIL&password=PASSWORD&to=\$uname7&text=\$pass&from=FROM\" keep-result=no];\
    \n\
    \n    :local newuser [:do {/tool user-manager user add username=\$uname password=\$pass customer=admin copy-from=test disabled=no phone=\$uname7} on-error={}];   \
    \n\
    \n\
    \n    #Add user to user-manager  \
    \n\
    \n\
    \n\
    \n    :if ((\$sendtest=yes)&&[:pick \$content (\$pos1+11)] != \"d\") do={ \
    \n\
    \n    :do {(\$newuser&&\$timeoutsendsms&&\$sendsms)} on-error={};\
    \n\
    \n\
    \n\
    \n    }\
    \n\
    \n  \
    \n\
    \n     :if ((\$sendtest=yes)&&[:pick \$content (\$pos1+11)] = \"d\") do={\
    \n\
    \n\
    \n\
    \n     :do {(\$changepassword&&\$timeoutsendsms&&\$sendsms&&\$putpasschange)} on-error={};\
    \n\
    \n        \
    \n\
    \n         }\
    \n\
    \n        }\
    \n\
    \n\
    \n\
    \n       }\
    \n\
    \n\
    \n\
    \n      }\
    \n\
    \n     }\
    \n\
    \n\
    \n\
    \n      /system logging action set userman memory-lines=1;\
    \n\
    \n      :delay 1\
    \n\
    \n      /system logging action set userman memory-lines=1000;"
/tool user-manager database set db-path=user-manager
/tool user-manager router add coa-port=1700 customer=admin disabled=no ip-address=10.1.1.1 log=auth-ok,auth-fail,acct-ok,acct-fail name=testhotspot shared-secret=PassWord123 use-coa=no
/tool user-manager user add customer=admin disabled=no ipv6-dns=:: password=PassWord123 shared-users=5 username=test wireless-enc-algo=none wireless-enc-key="" wireless-psk=""
