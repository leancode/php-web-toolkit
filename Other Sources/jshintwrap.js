
// BEGIN JSHINT-WRAPPER

/*module.exports = {
reporter: function (res) {
	var len = res.length;
	var str = "";
	
	res.forEach(function (r) {
				var file = r.file;
				var err = r.error;
				
				str += file + ": line " + err.line + ", col " +
				err.character + ", " + err.reason + "\n";
                });
	
	if (str) {
		process.stdout.write(str + "\n" + len + " error" +
							 ((len === 1) ? "" : "s") + "\n");
	}
}
};
*/

var JSHINTWRAP = function (input, prefs) {
	
	prefs = prefs.split(',');
	var options = {'predef': ['window', 'self'], 'maxerr' : 100};
	for (var i = 0; i < prefs.length; i++) {
		if (prefs[i] != '') {
			options[prefs[i]] = true;
		}
	}
	
	var results = "";
	var report = "";
	var err_desc = "";
	var mystatus = JSHINT(input, options);
	for (var i = 0; i < JSHINT.errors.length; i++) {
		report = report + "Line " + JSHINT.errors[i].line + " col " + JSHINT.errors[i].character + ": " + JSHINT.errors[i].reason + "<br>\n";
	}
	//	var report = JSHINT.reporter(results, input, options);
	
	if (mystatus === true) {
		if (!report) {
			print('No warnings or errors were found');
			return;
		}
		else {
			err_desc = '<h2 class="warning">Warning: Implied Globals</h2>';
		}
	}
	else {
		var err = JSHINT.errors;
		if (err[err.length - 1] === null) {
			err_desc = '<h2 class="error">Fatal Error</h2>';
		}
		else {
			err_desc = '<h2 class="error">Error(s)</h2>';
		}
	}
	print(err_desc+"\n");
	print(report);
};

if (!arguments[0] || !arguments[1]) {
	print('No input received...');
}
else {
	JSHINTWRAP(arguments[0], arguments[1]);
}
	