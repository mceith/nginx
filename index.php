<?php
   //Connecting to Redis server on localhost
   $redis = new Redis();
   $redis->connect('DBADDR', 6379);
   //set the data in redis string
   $redis->setnx($_SERVER['REMOTE_ADDR'], 1);
   // Get the stored data and print it
   $redis->incr($_SERVER['REMOTE_ADDR']);
   $host_ip = $_SERVER['REMOTE_ADDR'];
   $count = $redis->get($_SERVER['REMOTE_ADDR']);
   $self = $_SERVER['SERVER_ADDR'];
   print "Hey you $host_ip, this is your $count visit on container $self!!";
?>
