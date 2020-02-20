<?php

use PEAR2\Net\RouterOS;
date_default_timezone_set('Europe/Moscow');

require_once 'config.php';
require_once 'includes/PEAR2_Net_RouterOS-1.0.0b6/src/PEAR2/Autoload.php';

if (!isset($argv[1]) || empty($argv[1]) || !is_numeric($argv[1])) die("No CallerID's found! Aborted!\n");

try {
        $client = new RouterOS\Client($arr_logon['ip_addr'], $arr_logon['login'], $arr_logon['pass']);
    }

    catch (Exception $e) {
        echo ('Unable to connect to the router with message: '.$e);
        return false;
    }

// Bring the string to the form
    $num = trim($argv[1]);
    $len = strlen($num);
    if ($len > 10) $num = substr($num, -10);
    
// Send Request
    $request = new RouterOS\Request('/ip/hotspot/user/add');
    $request->setArgument('name', $num);
    $request->setArgument('password', $num);

    $responses = $client->sendSync($request);

    //echo "Done!\n";
?>