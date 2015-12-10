<?php
   $redis = new Redis();
   $redis->connect('DBADDR', 6379);
   $redis->setnx($_SERVER['REMOTE_ADDR'], 1);
   $redis->incr($_SERVER['REMOTE_ADDR']);
         $host_ip = $_SERVER['REMOTE_ADDR'];
         $redis = new Redis();
         $redis->connect('redis-slave', 6379);
   $count = $redis->get($_SERVER['REMOTE_ADDR']);
   $self = $_SERVER['SERVER_ADDR'];
   //phpinfo();
   $server_info = $redis->info();
   $array = array_values($server_info);
   $redis_server = $array[10];
   print "Hey You! $host_ip, this is your $count visit on container $self and redis-slave $redis_server";
?>
