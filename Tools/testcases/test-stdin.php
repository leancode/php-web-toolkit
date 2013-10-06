#!/usr/bin/php
<?php
//$stdin = fopen('php://stdin', 'r');
		$line = fread(STDIN, 99999999);
echo strlen($line)." bytes read";
echo $line;

function blubb() {
			return 3;
	}
?>