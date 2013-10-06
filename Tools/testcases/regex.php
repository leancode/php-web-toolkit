<?php

function bookend($text, $start) {

	// return modified text
	
	// \w+ {n,}
	// (?<=,|^)([^ ]*)( \1)+(?=,|$) 
	$match = preg_replace('/(?<= |^)([^ ]*)(( \1){'.$start.',})(?= |$)/', '(\\0)[\\1][\\2][\\3]', $text);
	
	$match = preg_replace('/(?<= |^)([^ ]*)(( \1){'.($start-0).',})(?= |$)/', ' 0:[\\0] 1:[\\1] 2:[\\2] ', $text);
	// ^([^\r\n]*)$(.*?)(?:(?:\r?\n|\r)\1$)+
	
	/*
	function bookend(text, start) {
		return text.replace(new RegExp('((\\w+)(?:\\s\\2){' + (start - 1) + '})\\s((?:\\s?\\2)+)', 'g'), '$1 ($3)');
	}
	*/
	return $match;
}

$example = 'a a a a a a a a a bb bb c c c c d a dd dd dd dd dd dd';



$result = bookend($example, 3);

echo $result."<br>\n";

// result is 'a a a (a a a a a a) bb bb c c c (c) d a dd dd dd (dd dd dd)'



$result2 = bookend($example, 4);

echo $result2."<br>\n";

// result2 is 'a a a a (a a a a a) bb bb c c c c d a dd dd dd dd (dd dd)'

?>