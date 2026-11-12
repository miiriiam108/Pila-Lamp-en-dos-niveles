<?php

define('DB_HOST', '192.168.10.11');
define('DB_NAME', 'lamp_db');
define('DB_USER', 'appuser');
define('DB_PASSWORD', 'appuser123');

$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

?>