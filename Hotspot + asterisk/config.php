<?php

/*Connect to Mikrotik __OLD_CONFIG*/
/*$mik_logon = array(
			array('ip_addr' => '192.168.170.198', 'login' => 'admin', 'pass' => '', 'name' => '367'),
			array('ip_addr' => '192.168.170.196', 'login' => 'admin', 'pass' => '', 'name' => '368')
);*/

// array MAC autogenerate
//$arr_automac = array("DA:A1:19");

/*Config Mikrotik*/
define('DURATION', '30');
//define('INTERFACE_WIRELESS', 'wlan1');
define('MAX_BEACON_STRENGTH', -110);
define('START_WORK_TIME','10:00');
define('END_WORK_TIME','19:00');

define('HOST','localhost');
define('DB_NAME','wiflow');
define('DB_USER','root');
define('DB_PASSWORD','mozc__WSZOL5');

/*Config Mikrotik Guide*/
$arr_logon = array(
	'ip_addr' => '192.168.170.198',
	'login' => 'admin',
	'pass' => ''
);

?>