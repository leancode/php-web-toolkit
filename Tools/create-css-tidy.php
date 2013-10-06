<?php

$files = array('class.csstidy_ctype.php', 'data.inc.php', 'class.csstidy_print.php', 'class.csstidy_optimise.php', 'class.csstidy.php');

$out = '<?php'."\n";

foreach ($files as $file) {
	$code = file_get_contents($file);
	$code = str_replace("<?php\n", '', $code);
	$code = preg_replace("/require_once\('[a-z_\.]+'\);/", '', $code);	
	$code = preg_replace("/require\('[a-z_\.]+'\);/", '', $code);	
	$code = str_ireplace('$GLOBALS[\'csstidy\'][\'predefined_templates\'][\'default\'][] = \'<span class="property">\';', '$GLOBALS[\'csstidy\'][\'predefined_templates\'][\'default\'][] = \'	<span class="property">\';', $code);
	$code = str_ireplace('$GLOBALS[\'csstidy\'][\'predefined_templates\'][\'default\'][] = \'\'; //indent in @-rule', '$GLOBALS[\'csstidy\'][\'predefined_templates\'][\'default\'][] = \'	\'; //indent in @-rule', $code);
	$out .= $code;
}

$out .= '
	
	/* PHP & Web Toolkit specific code starts here */
	/* using csstidy 1.4 devel */
	/* view also https://github.com/Cerdic/CSSTidy and https://github.com/Hambrook/CSSTidy */
	
	// init
	ini_set(\'display_errors\',\'Off\');
	$command = \'\';
	$files = array();
	$options = array();
	
	$css = new csstidy();
	
	// csstidy config + template
	$css->set_cfg(\'sort_selectors\', false);
	$css->set_cfg(\'sort_properties\', false);
	$css->set_cfg(\'case_properties\', 1);
	$css->set_cfg(\'merge_selectors\', 1);
	$css->set_cfg(\'preserve_css\', false);
	$css->set_cfg(\'css_level\', \'CSS3.0\');
	
	$template = \'default\';
	if (isset($argv[1]) && $argv[1] == \'-t\' && isset($argv[2]) && strlen($argv[2]) > 0) {
		$template = $argv[2];
	}
	if (isset($argv[2]) && $argv[2] == \'default_sorted\') {
		$css->set_cfg(\'sort_properties\', true);
		$css->set_cfg(\'sort_selectors\', true);
		
		$template = \'default\';
	}
	else if (isset($argv[2]) && $argv[2] == \'highest_compression\') {
		$css->set_cfg(\'merge_selectors\', 2);
	}
	else {
		$css->set_cfg(\'preserve_css\', true);
	}
	
	$css->load_template($template);
	
	// line endings
	$line_endings = \'NA\';
	if (isset($argv[3]) && $argv[3] == \'-l\' && isset($argv[4]) && strlen($argv[4]) > 0) {
		$line_endings = $argv[4];
	}
	// remove last ;
	if (isset($argv[5]) && $argv[5] == \'-last\' && isset($argv[6]) && strlen($argv[6]) > 0) {
		$css->set_cfg(\'remove_last_;\', $argv[6]);
	}
	
	// read stdin
	$source_orig_cli = \'\';
	while ($inp = fread(STDIN,8192)) {
		$source_orig_cli .= $inp;
	}
	$css_code = $source_orig_cli;
	
	// execute csstidy, re-insert line endings and output result
	if ($css->parse($css_code)) {
		$result = $css->print->plain();
		$result = preg_replace(\'/(@import "url\(([^"]+)\)")/\', \'@import url("\\2")\', $result);
		
		switch ($line_endings) {
			case \'CRLF\':
				$result = str_replace("\n", "\r\n", $result);
				break;
			case \'CR\':
				$result = str_replace("\n", "\r", $result);
				break;
			case \'LF\':
				$result = str_replace("\r","\n", $result);
				break;
		}
		echo $result;
	}
	else {
		echo "!ERROR parsing";
	}
';

file_put_contents('csstidy.php', $out);

?>