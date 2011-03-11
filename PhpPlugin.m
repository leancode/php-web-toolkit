//
//  PhpPlugin.m
//  PhpPlugin
//
//  Created by Mario Fischer on 23.12.08.
//  Copyright 2008-2011 chipwreck.de. All rights reserved.

/*
 @TODO: phptidy configurable (continue)
		$fix_token_case = true; $fix_builtin_functions_case = true; $indent = true; $replace_inline_tabs = true;  $replace_phptags = true; 
		$add_file_docblock = false;	$add_function_docblocks = false; $add_doctags = false; $fix_docblock_space = false;		
 
 @TODO: NS_Log(@"RES: %@", [JSHelper executeScript:@"function myfunc(i){return i;}; myfunc('hallo');"]);
 
 @TODO: 
 */

#import "PhpPlugin.h"
#import "CodaPlugInsController.h"
#import "PreferenceController.h"
#import "MessagingController.h"
#import "UpdateController.h"
#import "ValidationResult.h"

@implementation PhpPlugin

#pragma mark Required Coda Plugin Methods

- (id)initWithPlugInController:(CodaPlugInsController *)aController bundle:(NSBundle *)yourBundle
{
	if ( (self = [super init]) != nil ) {
		
		// prefs
		preferenceController = [[PreferenceController alloc] init];
		[preferenceController setDefaults];
		[preferenceController setBundlePath:[yourBundle resourcePath]];
		[preferenceController setMyPlugin:self];
		
		// messaging
		messageController = [[MessagingController alloc] init];
		[messageController setBundlePath:[yourBundle resourcePath]];
		[messageController setMyPlugin:self];
		
		// updates
		updateController = [[UpdateController alloc] init];
		[updateController setMyPlugin:self];
		
		// init vars
		timeoutValue = 15.0;
		controller = aController;
		myBundle = yourBundle;
		versionNumber = [[myBundle infoDictionary] objectForKey:@"CFBundleVersion"];
		
		NSLog(@"Starting Coda PHPPlugin, version: %@ - report bugs at http://www.chipwreck.de", versionNumber);
				
		// Check sbjson
		int msg_shown = [[NSUserDefaults standardUserDefaults] integerForKey:PrefMsgShown];
		
		if (!msg_shown) {
			@try {
				SBJsonParser *json = [SBJsonParser alloc];
				if (![json respondsToSelector:@selector(objectWithString:error:)]) {
					int lesscssresp = [messageController alertInformation:@"Another plugin is not compatible with the PHP & WebToolkit plugin.\n\nProbably LessCSS or Mojo WebOS.\n\nIf you use the LessCSS plugin: Please uninstall and visit http://incident57.com/less/ to use Less.app instead."
								additional:@"Click OK to open the Plugins-folder, uninstall the Plugin and restart Coda.\n\nThis message appears only once, but proCSSor is disabled until the conflict is resolved."
							  cancelButton:YES];

					if (lesscssresp == 1) {
						NSString *lesscsspath = [@"~/Library/Application Support/Coda/Plug-Ins" stringByExpandingTildeInPath];
						[[NSWorkspace sharedWorkspace] selectFile:[lesscsspath stringByAppendingString:@"/LessCSS.codaplugin"] inFileViewerRootedAtPath:lesscsspath];
						[[NSWorkspace sharedWorkspace] selectFile:[lesscsspath stringByAppendingString:@"/MojoPlugin.codaplugin"] inFileViewerRootedAtPath:lesscsspath];
					}
					
					[[NSUserDefaults standardUserDefaults] setInteger:1 forKey: PrefMsgShown];
				}
			}
			@catch (NSException *e) {
				[messageController alertCriticalException:e];
			}
		}
		
		// PHP >>
		[controller registerActionWithTitle:NSLocalizedString(@"Validate PHP", @"") underSubmenuWithTitle:@"PHP"
									 target:self selector:@selector(validatePhp)
						  representedObject:nil keyEquivalent:@"$@v" pluginName:[self name]]; // cmd+shift+v
		
		[controller registerActionWithTitle:NSLocalizedString(@"Strip Whitespace and Comments", @"") underSubmenuWithTitle:@"PHP"
									 target:self selector:@selector(doStripPhp)
						  representedObject:nil keyEquivalent:@"$~@s" pluginName:[self name]]; // cmd+alt+shift+s
		
		[controller registerActionWithTitle:NSLocalizedString(@"Tidy PHP", @"") underSubmenuWithTitle:@"PHP"
									 target:self selector:@selector(doTidyPhp)
						  representedObject:nil keyEquivalent:@"$~@t" pluginName:[self name]]; // cmd+alt+shift+t
		
		// HTML >>		
		[controller registerActionWithTitle:NSLocalizedString(@"Validate HTML", @"") underSubmenuWithTitle:@"HTML"
									 target:self selector:@selector(doValidateHtml)
						  representedObject:nil keyEquivalent:@"$~@v" pluginName:[self name]]; // cmd+alt+shift+v
		
		[controller registerActionWithTitle:NSLocalizedString(@"Validate HTML online", @"") underSubmenuWithTitle:@"HTML"
									 target:self selector:@selector(doValidateRemoteHtml)
						  representedObject:nil keyEquivalent:nil pluginName:[self name]]; // 
		
		[controller registerActionWithTitle:NSLocalizedString(@"Tidy HTML", @"") underSubmenuWithTitle:@"HTML"
									 target:self selector:@selector(doTidyHtml)
						  representedObject:nil keyEquivalent:@"$~@h" pluginName:[self name]]; // cmd+alt+shift+h
		
		// CSS >>	
		
		[controller registerActionWithTitle:NSLocalizedString(@"Validate CSS online", @"") underSubmenuWithTitle:@"CSS"
									 target:self selector:@selector(doValidateRemoteCss)
						  representedObject:nil keyEquivalent:nil pluginName:[self name]]; // 
		
		[controller registerActionWithTitle:NSLocalizedString(@"Tidy CSS", @"") underSubmenuWithTitle:@"CSS"
									 target:self selector:@selector(doTidyCss)
						  representedObject:nil keyEquivalent:@"~@t" pluginName:[self name]]; // alt+shift+t
		
		[controller registerActionWithTitle:NSLocalizedString(@"Format with ProCSSor", @"") underSubmenuWithTitle:@"CSS"
									 target:self selector:@selector(doProcssorRemote)
						  representedObject:nil keyEquivalent:@"$~@p" pluginName:[self name]]; // cmd+alt+shift+p
		
		// JS >>
		
		[controller registerActionWithTitle:NSLocalizedString(@"JS Lint", @"") underSubmenuWithTitle:@"JS"
									 target:self selector:@selector(doJsLint)
						  representedObject:nil keyEquivalent:@"$~@j" pluginName:[self name]]; // cmd+alt+shift+j
		
		[controller registerActionWithTitle:NSLocalizedString(@"Minify Javascript", @"") underSubmenuWithTitle:@"JS"
									 target:self selector:@selector(doJsMinify)
						  representedObject:nil keyEquivalent:nil pluginName:[self name]]; //
		
		[controller registerActionWithTitle:NSLocalizedString(@"Tidy Javascript", @"") underSubmenuWithTitle:@"JS"
									 target:self selector:@selector(doJsTidy)
						  representedObject:nil keyEquivalent:@"$~^j" pluginName:[self name]]; // cmd+alt+ctrl+j
		
		// root >>
		
		[controller registerActionWithTitle:NSLocalizedString(@"Check for updates", @"") underSubmenuWithTitle:nil
									 target:self selector:@selector(checkForUpdateNow)
						  representedObject:nil keyEquivalent:nil pluginName:[self name]]; // 
		
		
		[controller registerActionWithTitle:NSLocalizedString(@"Help!", @"") underSubmenuWithTitle:nil
									 target:self selector:@selector(goToHelpWebsite)
						  representedObject:nil keyEquivalent:nil pluginName:[self name]]; // 
		
		[controller registerActionWithTitle:NSLocalizedString(@"Preferences/About...", @"") underSubmenuWithTitle:nil
									 target:self selector:@selector(showPreferencesWindow)
						  representedObject:nil keyEquivalent:@"$~@," pluginName:[self name]]; // cmd+alt+shift+,
		
		// Check startup msg
		NSString * last_version_run = [[NSUserDefaults standardUserDefaults] stringForKey:PrefLastVersionRun];
		if (![last_version_run isEqualToString: [self pluginVersionNumber]]) {
			[messageController showInfoMessage:[@"PHP & Web Toolkit updated to " stringByAppendingString: [self pluginVersionNumber]] 
									additional:@"If you have problems:\nMenu: Plug-Ins > PHP & Web Toolkit > Help\n\n(This message appears only once for each update.)"
										sticky:YES
			 ];
			[[NSUserDefaults standardUserDefaults] setObject:[self pluginVersionNumber] forKey: PrefLastVersionRun];
		}
		
		// check for updates (autocheck)
		[updateController checkForUpdateAuto];
	}
	
	return self;
}

- (NSString *)name
{
	return @"PHP & Web Toolkit";
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	SEL action = [aMenuItem action];
	
	if ( ![self editorTextPresent] ) {
		if (action != @selector(showPreferencesWindow) && action != @selector(checkForUpdateNow) && action != @selector(goToHelpWebsite) ) {
			return NO;
		}
	}
	return YES;
}

#pragma mark Local Validation

- (void)doValidateHtml
{
	[messageController clearResult:self];
	
	CodaTextView	*textView = [controller focusedTextView:self];
	NSMutableArray	*args = [NSMutableArray array];
	
	[args addObject:@"-config"];
	[args addObject:[[myBundle resourcePath] stringByAppendingString:@"/tidy_config_check.txt"]];
	[args addObject:@"--newline"];
	[args addObject:[self currentLineEnding:textView]];
	[args addObject:[self currentEncoding:textView]];
	
	ValidationResult *myresult = [self validateWith:[self tidyExecutable] arguments:args called:@"Tidy" showResult:YES];
		
	if ([myresult hasErrorMessage]) {
		[messageController showResult:[NSString stringWithFormat:@"<style type='text/css'>pre{font-family:sans-serif;font-size: 13px;}</style><pre>%@</pre>",[self escapeEntities:[[myresult result] mutableCopy]]]
							   forUrl:@""
		 					withTitle:@"Tidy validation result"
		 ];
	}
}

- (void)validatePhp
{
	NSMutableArray	*args = [NSMutableArray arrayWithObjects:@"-l", @"-n", @"--", nil];
	ValidationResult *myresult = [self validateWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"PHP" showResult:NO];

	if ([myresult hasErrorMessage]) {
		NSBeep();
		int lineOfError = 0;
		NSScanner *scanner = [NSScanner scannerWithString:[myresult result]];
		[scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
		[scanner scanInt: &lineOfError];
		
		[messageController openSheetPhpError:[[myresult result] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] atLine:lineOfError forWindow:[[controller focusedTextView:self] window]];
	}
	else if ([myresult valid]) {
		NSMutableString *addInfo = [NSMutableString stringWithString:@""];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefAutoSave]) {
			[[controller focusedTextView:self] save];
			[addInfo appendString:@"File was automatically saved."];
		}
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefPhpBeepOnly]) {
			[[NSSound soundNamed:@"Tink"] play];
		}
		else {
			[messageController showInfoMessage:@"No PHP syntax errors" additional:addInfo];
		}	
	}
	else {
		[messageController alertCriticalError:@"Error parsing PHP - this should not happen" additional:@"Please check the preferences"];
	}
}

- (void)doJsLint
{
	[messageController clearResult:self];
	
	NSMutableArray *args = [NSMutableArray arrayWithObject:[[myBundle resourcePath] stringByAppendingString:@"/jshint-min.js"] ];
	ValidationResult *myresult = [self validateWith:[[myBundle resourcePath] stringByAppendingString:@"/js-call.sh"] arguments:args called:@"JSLint" showResult:YES];
	
	if ([myresult hasErrorMessage]) {
				[messageController showResult:[myresult result]
							   forUrl:@""
		 					withTitle:@"JSLint validation result"
		 ];
	}
}

#pragma mark Remote Validation

- (void)doValidateRemoteHtml
{
	if (![self editorTextPresent]) {
		NSBeep();
		return;
	}
	[messageController clearResult:self];

	NSMutableArray	*args = [NSMutableArray array];
	
	[args addObject:@"-s"]; // silent
	[args addObject:@"-S"]; // show error
	
	[args addObject:@"-F"];
	[args addObject:@"ss=1"]; // ss = 1 => Show source code, for w3c-validator
	
	[args addObject:@"-F"];
	[args addObject:@"showsource=yes"]; // for validator.nu
	
	[args addObject:@"-F"];
	[args addObject:@"ucn_task=custom"]; // for unicode validator	
	[args addObject:@"-F"];
	[args addObject:@"tests=markup-validator"]; // or: css-validator	
	[args addObject:@"-F"];
	[args addObject:[@"profile=" stringByAppendingString: [[CssLevel configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefCssLevel]] cmdLineParam] ]];
	
	NSString *fileUrl =  [ [[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorParamFile] stringByAppendingString:@"=@-" ];
	NSString *paramUrl = [fileUrl stringByAppendingString:@";type=text/html"];
	
	[args addObject:@"-F"];
	[args addObject: paramUrl];
	[args addObject: [[NSUserDefaults standardUserDefaults] stringForKey:PrefHtmlValidatorUrl]];
	
	NSMutableString *resultText = [self executeFilter:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCurlLocal] arguments:args usestdout:YES];
	
	if (resultText == nil || [resultText length] == 0) {
		[messageController alertCriticalError:@"No output from HTML online service received." additional:@"Make sure you're online and check the Preferences."];
	}
	else {
		
		[messageController showResult:[self improveWebOutput:resultText fromDomain:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]] 
							   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]
							withTitle:[@"HTML validation result via " stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]]
		 ];
	}
}

- (void)doValidateRemoteCss
{
	if (![self editorTextPresent]) {
		NSBeep();
		return;
	}
	
	[messageController clearResult:self];

	NSMutableArray *args = [NSMutableArray array];
	
	[args addObject:@"-s"]; // silent
	[args addObject:@"-S"]; // show error
	
	NSString * fileUrl =  [ [[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorParamFile] stringByAppendingString:@"=@-" ];
	NSString * paramUrl = [fileUrl stringByAppendingString:@";type=text/css"];
		
	[args addObject:@"-F"];
	[args addObject:[@"profile=" stringByAppendingString: [[CssLevel configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefCssLevel]] cmdLineParam] ]];
	
	[args addObject:@"-F"];
	[args addObject: paramUrl];
	[args addObject: [[NSUserDefaults standardUserDefaults] stringForKey:PrefCssValidatorUrl]];
	
	NSMutableString *resultText = [self executeFilter:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCurlLocal] arguments:args usestdout:YES];
	
	if (resultText == nil || [resultText length] == 0) {
		[messageController alertCriticalError:@"No output from CSS online service received." additional:@"Make sure you're online and check the Preferences."];
	}
	else {
		[messageController showResult:[self improveWebOutput:resultText fromDomain:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]] 
							   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]
							withTitle:[@"CSS validation result via " stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]]
		 ];
	}
}

#pragma mark Tidy HTML/CSS/PHP

-(void)doTidyHtml
{
	NSString *myConfig = [[HtmlTidyConfig configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefHtmlTidyConfig]] cmdLineParam];
	NSString *configFile = [[myBundle resourcePath] stringByAppendingString:[[@"/tidy_config_format_" stringByAppendingString:myConfig] stringByAppendingString:@".txt"]];
	
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-config", configFile, @"--newline", [self currentLineEnding:[controller focusedTextView:self]], [self currentEncoding:[controller focusedTextView:self]], nil];
	[self reformatWith:[self tidyExecutable] arguments:args called:@"tidy"];
}

-(void)doTidyCss
{
	NSString *myConfig = [[CssTidyConfig configForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:PrefCssTidyConfig]] cmdLineParam];

	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-t", myConfig, @"-l", [self currentLineEnding:[controller focusedTextView:self]], nil];
	[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/csstidy.php"] arguments:args called:@"CSSTidy"];
}

- (void)doStripPhp
{
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-w", @"--", nil];	
	[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"PHP Strip"];
}

- (void)doTidyPhp
{
	NSMutableArray *args = [NSMutableArray array];
	
	[args addObject:@"-l"];
	[args addObject: [self currentLineEnding:[controller focusedTextView:self]]];
	
	int myPhpTidyBracesConfigIdx = [[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyBraces];
	NSString *myConfig = [[PhpTidyConfig configForIndex: myPhpTidyBracesConfigIdx] cmdLineParam];
	
	[args addObject:@"-b"];
	[args addObject:myConfig];
	
	[args addObject:@"-a"];
 	if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyBlankLines] == 1) {
		[args addObject:@"1"];
	}
	else {
		[args addObject:@"0"]; 		 
	}
	
	[args addObject:@"-w"];
 	if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyWhitespace] == 1) {
		[args addObject:@"1"];
	}
	else {
		[args addObject:@"0"]; 		 
	}
	
	[args addObject:@"-c"];
 	if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyComma] == 1) {
		[args addObject:@"1"];
	}
	else {
		[args addObject:@"0"]; 		 
	}
	
	[args addObject:@"-f"];
 	if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyFixBrackets] == 1) {
		[args addObject:@"1"];
	}
	else {
		[args addObject:@"0"]; 		 
	}
		
	[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/phptidy-coda.php"] arguments:args called:@"PHPTidy"];
}

#pragma mark proCSSor

- (void)doProcssorRemote
{
	if (![self editorTextPresent]) {
		NSBeep();
		return;	
	}
	
	NSMutableArray *args = [NSMutableArray array];
	
	[args addObject:@"-s"]; // silent
	[args addObject:@"-S"]; // show error

	[args addObject:@"-F"]; // post as form value:
	[args addObject:@"source=file"];

	if (![[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSafe] isEqualToString:@"1"] ) {
		[args addObject:@"-F"]; // sort
		[args addObject:[[CssProcssor configForIntvalueSorting:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcSort]] cmdLineParam]];
		
		if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcGrouping] != nil) {
			[args addObject:@"-F"]; // group
			[args addObject:[NSString stringWithFormat:@"grouping=%@",[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcGrouping]]];
		}
	}
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcSafe] != nil) {
		[args addObject:@"-F"]; // safe mode
		[args addObject:[NSString stringWithFormat:@"safe=%@",[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSafe]]];
	}
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules] != nil) {
		[args addObject:@"-F"]; // indent rules
		[args addObject:[NSString stringWithFormat:@"indent_rules=%@",[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules]]];
	}
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules] isEqualToString:@"1"] ) {
			//	[args addObject:@"-F"]; [args addObject:[[CssProcssor configForIntvalueIndentLevels:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcIndentLevel]] cmdLineParam]];
		
		[args addObject:@"-F"]; // indent how
		[args addObject:@"indent_type=space"];
	}
	else if ([[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcColumnize] isEqualToString:@"1"] ) {
		
		[args addObject:@"-F"]; // columnize
		[args addObject:[NSString stringWithFormat:@"tabbing=%@",[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcColumnize]]];

		[args addObject:@"-F"]; // columnize left/right
		[args addObject:[[CssProcssor configForIntvalueAlignment:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcAlignment]] cmdLineParam]];
	}
	
	[args addObject:@"-F"]; // formatting
	[args addObject:[[CssProcssor configForIntvalueFormatting:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcFormatting]] cmdLineParam]];
	
	[args addObject:@"-F"]; // braces
	[args addObject:[[CssProcssor configForIntvalueBraces:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcBraces]] cmdLineParam]];
		
	[args addObject:@"-F"]; // indent properties size
	[args addObject:[[CssProcssor configForIntvalueIndentSize:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcIndentSize]] cmdLineParam]];

	if ([[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSelectorsSame] != nil) {
		[args addObject:@"-F"]; // selectors on same line?
		[args addObject:[NSString stringWithFormat:@"selectors_on_same_line=%@",[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSelectorsSame]]];		
	}

	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcBlankLine] != nil) {
		[args addObject:@"-F"]; // blank lines
		[args addObject:[NSString stringWithFormat:@"blank_line_rules=%@",[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcBlankLine]]];
	}

	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcDocblock] != nil) {
		[args addObject:@"-F"]; // improve docblock
		[args addObject:[NSString stringWithFormat:@"docblock=%@",[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcDocblock]]];
	}
	
	[args addObject:@"-F"]; // post as form value:
	[args addObject:@"css=@-;type=text/css"];
	[args addObject: [[NSUserDefaults standardUserDefaults] stringForKey:PrefProCSSorUrl]];
	
	NSMutableString *resultText = [self executeFilter:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCurlLocal] arguments:args usestdout:YES];

	if (resultText == nil || [resultText length] == 0) {
		[messageController alertCriticalError:@"No output from proCSSor online service received." additional:@"Make sure you're online and check the Preferences."];
	}
	else {
		NSError *error;
		SBJsonParser *json = [SBJsonParser alloc];
		
		if (![json respondsToSelector:@selector(objectWithString:error:)] ) {
			[json release];
			[messageController alertCriticalError:@"Sorry - an incompatible plug-in was found.\n\nPlease remove this plugin first." additional:@"Remove the LessCSS-plugin or WebMojo-plugin if present or report a bug on www.chipwreck.de"];
		}
		else {
			NSMutableDictionary *jsonResult = [json objectWithString:resultText error:&error];
			if (jsonResult == nil) {
				[json release];
				[messageController alertCriticalError:@"Invalid response from proCSSor received." additional:[error localizedDescription]];
				return;
			}
			NSString *cssResult = [jsonResult objectForKey:@"css"];
			if (cssResult == nil || [cssResult length] == 0) {
				[json release];
				[messageController alertCriticalError:@"No CSS received, make sure the CSS file is valid" additional:@"(No JSON object called 'css' from proCSSor received.)"];
				return;
			}		
			
			[self replaceEditorTextWith:cssResult];	
			[json release];
			[messageController showInfoMessage:@"proCSSor done"];
		}
	}
}

#pragma mark JS Tidy/Minify

- (void)doJsTidy
{
	NSMutableArray *args = [NSMutableArray arrayWithObject:[[myBundle resourcePath] stringByAppendingString:@"/jstidy-min.js"]];
	[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/js-call.sh"] arguments:args called:@"JSTidy"];
}

- (void)doJsMinify
{
	[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/jsminify.php"] arguments:[NSMutableArray array] called:@"JSMinify"];
}

#pragma mark Updates

- (void)checkForUpdateNow
{
	int avail = [updateController isUpdateAvailable];
	if (avail == 1) {
		int res = [messageController alertInformation:@"An update for PHP & Web Toolkit is available!\nClick OK to download. (Restart Coda after installing)" additional:@"You can enable automatic checking for updates in Preferences." cancelButton:YES];
		if (res == 1) {
			[self downloadUpdate:nil];
		}
	}
	else if (avail == 0) {
		[messageController showInfoMessage:@"No update available" additional:@"You can enable automatic checking for updates in Preferences."];
	}
	else if (avail == 3) {
		[messageController alertCriticalError:@"Could not check for updates, please make sure you're connected to the internet or try again later." additional:@"You can disable the automatic check in the preferences."];
	}
}

- (void)showUpdateAvailable
{
	int res = [messageController alertInformation:@"An update for PHP & Web Toolkit is available!\nClick OK to download in your browser." 
									   additional:@"You can disable automatic checking for updates in Preferences." cancelButton:YES];
	if (res == 1) {
		[self downloadUpdate:nil];					
	}	
}

- (IBAction)downloadUpdate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [ 
											 NSURL URLWithString: [@"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=" stringByAppendingString: versionNumber] 
											 ] 
	 ];
}

#pragma mark Helper methods

- (NSMutableString *)escapeEntities:(NSMutableString *)myString
{
    [myString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [myString length])];

    return myString;
}

- (NSString *)improveWebOutput:(NSString *)input fromDomain:(NSString *)domain // Hacked stuff..improve w3c output with absolute links DON'T ASK!
{
	if (input == nil) return @"";
	
	NSString *baseDomain = [[domain stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
	return
		[
		 [		   
		  [
		   [input
			stringByReplacingOccurrencesOfString:@"src=\"images/" withString: [[@"src=\"" stringByAppendingString: baseDomain] stringByAppendingString:@"images/"] ]
		   stringByReplacingOccurrencesOfString:@"@import \"./style/" withString: [[@"@import \"" stringByAppendingString: baseDomain] stringByAppendingString:@"style/"] ]
		  stringByReplacingOccurrencesOfString:@"rel='stylesheet' href='style/" withString:[@"rel='stylesheet' href='" stringByAppendingString: baseDomain] ]
		stringByReplacingOccurrencesOfString:@"link href=\"./style/" withString: [[@"link href=\"" stringByAppendingString: baseDomain] stringByAppendingString:@"style/"]
	];
}

- (void)goToHelpWebsite
{
	[preferenceController goToHelpWebsite:self];
}

- (void)showPreferencesWindow
{
	[preferenceController showWindow:self];
}

- (void)doLog:(NSString *)loggable
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefDebugMode])  {
		NSLog(@"[Coda PHP Toolkit] %@", loggable);
	}	
}

#pragma mark Editor actions

- (void)displayHtmlString:(NSString*)data
{
	[controller displayHTMLString:data];
}

- (void)goToLine:(int)lineNumber
{
	unsigned numCharsInLine = 0;
	unsigned pos = 0;
	unsigned numIterations = 0;
	int currLineNumber = 0;
	int prevLineNumber = -1;
	int charsForLE = 1;
	
	CodaTextView *textView = [controller focusedTextView:self];
	[textView setSelectedRange: NSMakeRange(0, 0)];
	if ([[textView lineEnding] isEqualToString:@"\r\n"]) {
		charsForLE = 2;
	}
	
	@try {
		while (true) {
			currLineNumber = [textView currentLineNumber];
			if (prevLineNumber == currLineNumber && numIterations > 10) {
				[messageController alertCriticalError:@"Could not execute goToLine()" additional:@"Please use Mac or Unix line endings if possible"];
				break;
			}
			if (currLineNumber >= lineNumber || numIterations > 65536) {
				break;
			}
			
			pos = [textView startOfLine];
			numCharsInLine = [textView rangeOfCurrentLine].length;
			pos = pos + numCharsInLine + charsForLE;
			
			[textView setSelectedRange: NSMakeRange(pos, 0)];
			numIterations++;
			prevLineNumber = currLineNumber;
		}
		[textView setSelectedRange: NSMakeRange(pos, 0)]; // [textView rangeOfCurrentLine].length
	}
	@catch (NSException * e) {
		[messageController alertCriticalException:e];
	}
}

- (NSString *)getEditorText
{
	CodaTextView *textView = [controller focusedTextView:self];
	if ([self editorSelectionPresent]) {
		return [textView selectedText];
	}
	
	return [textView string];
}

- (BOOL)editorSelectionPresent
{
	CodaTextView *textView = [controller focusedTextView:self];
	return ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUseSelection] && [textView selectedText] != nil && [[textView selectedText] length] > 5);
}

- (BOOL)editorTextPresent /* Is a textview present and does it contain text? */
{
	CodaTextView *textView = [controller focusedTextView:self];
	
	if ( textView != nil && textView ) {
		NSString *text = nil;
		text = [textView string];
		if ( text != nil && [text length] > 0 ) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)editorPathPresent /* Is a textview path present? @deprecated */
{	
	CodaTextView *textView = [controller focusedTextView:self];
	return ([textView path] != nil);
}

- (void)replaceEditorTextWith:(NSString *)newText
{
	CodaTextView *textView = [controller focusedTextView:self];
	
	if (newText == nil || [newText length] < 1) {
		[messageController alertCriticalError:@"No new text received in replaceEditorTextWith." additional:@"This should not happen, please report a bug at www.chipwreck.de"];
	}
	else {
		NSRange endRange;
		if ([self editorSelectionPresent]) {
			endRange = [textView selectedRange];
		} else {
			endRange.location = 0;
			endRange.length = [[textView string] length];
		}
		
		[textView replaceCharactersInRange:endRange withString: newText];
	}
}

- (NSString *)currentLineEnding:(CodaTextView *)myview /* Get current line ending as string (CR, LF, CRLF) */
{
	if ([[myview lineEnding] isEqualToString:@"\r\n"]) {
		return @"CRLF";
	}
	if ([[myview lineEnding] isEqualToString:@"\n"]) {
		return @"LF";
	}
	return @"CR";
}

- (NSString *)currentEncoding:(CodaTextView *)myview /* Get current encoding as string (utf8, macroman,..) */
{
	Encoding *encodingObj = [Encoding encodingForIntvalue:[myview encoding]];
	if (encodingObj.cmdLineParam != nil) {
		return encodingObj.cmdLineParam;
	}
	return nil;
}

#pragma mark Information getters

- (NSString *)pluginVersionNumber
{
	return versionNumber;
}

- (NSString *)pluginIconPath
{
	return [[myBundle resourcePath] stringByAppendingString:@"/codaphp-plugin-icon.png"];
}

- (NSString *)phpVersion
{
	NSString *resultText = nil;
	
	NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-v"];
	
	NSString *result = [self filterTextInput:@"" with:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] options:args encoding:NSUTF8StringEncoding useStdout:YES];
	if (result != nil) {
		resultText = [NSString stringWithString:result];
	}
	
	if (resultText == nil || [resultText isEqualToString:@""]) {
		return @"ERROR - php not found";
	}
	
	return resultText;
}

- (NSString *)curlVersion
{
	NSString *resultText = nil;
	
	NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-V"];
	
	NSString *result = [self filterTextInput:@"" with: [[NSUserDefaults standardUserDefaults] stringForKey:PrefCurlLocal] options:args encoding:NSUTF8StringEncoding useStdout:YES];
	if (result != nil) {
		resultText = [NSString stringWithString:result];
	}
	
	if (resultText == nil || [resultText isEqualToString:@""]) {
		return @"ERROR - curl not found";
	}
	
	return resultText;
}

- (NSString *)tidyExecutable
{
	if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefTidyInternal] == 1) {
		return [[myBundle resourcePath] stringByAppendingString:@"/tidy"];
	}
	else {
		return [[NSUserDefaults standardUserDefaults] stringForKey:PrefTidyLocal];		
	};	
}

- (NSString *)tidyVersion
{
	NSString *resultText = nil;
	NSMutableArray *args = [NSMutableArray array];
	
    [args addObject:@"-v"];
	
	NSString *result = [self filterTextInput:@"" with: [self tidyExecutable] options:args encoding:NSUTF8StringEncoding useStdout:YES];
	if (result != nil) {
		resultText = [NSString stringWithString:result];
	}
	
	if (resultText == nil || [resultText isEqualToString:@""]) {
		return @"ERROR - HTMLTidy not found";
	}
	
	return resultText;
}

#pragma mark Growl

- (NSString *)growlNotify
{
	return [[myBundle resourcePath] stringByAppendingString:@"/growlnotify"];
}

#pragma mark Filter

- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show
{
	ValidationResult* myResult = [[ValidationResult alloc] init];
	
	if (![self editorTextPresent]) {
		NSBeep();
		[myResult release];
		return nil;
	}

	BOOL usesstdout = ![name isEqualToString:@"Tidy"];
	NSMutableString *resultText = [self executeFilter:command arguments:args usestdout:usesstdout];
	[myResult setResult:resultText];
	
	if (resultText == nil || [resultText length] == 0) {
		[messageController alertCriticalError:[name stringByAppendingString:@" returned nothing"] additional:@"Make sure the file has no errors and try using UTF-8 encoding."];
	}
	else {
		if ([resultText rangeOfString:@"No warnings or errors were found"].location != NSNotFound || [resultText rangeOfString:@"No syntax errors detected"].location != NSNotFound) {
			[myResult setValid:YES];
		}
	}
	
	if (show && [myResult valid]) {
		[messageController showInfoMessage:[name stringByAppendingString:@": No errors"] additional:resultText];
	}
	
	return [myResult autorelease];
}

- (void)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name
{
	if (![self editorTextPresent]) {
		NSBeep();
		return;
	}

	NSMutableString *resultText = [self executeFilter:command arguments:args usestdout:YES];
	
	if (resultText == nil || [resultText length] < 6) {
		[messageController alertCriticalError:[name stringByAppendingString:@" returned nothing"] additional:@"Make sure the file has no errors and try using UTF-8 encoding."];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"\nFatal"]) {
		[messageController alertCriticalError:@"Exception received." additional:[@"Make sure the file has no errors and try using UTF-8 encoding.\n\n" stringByAppendingString: resultText]];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"!ERROR"]) {
		[messageController alertCriticalError:[resultText substringFromIndex:1] additional:@"Make sure the file has no errors and try using UTF-8 encoding."];
	}
	else {
		[self replaceEditorTextWith:resultText];
		[messageController showInfoMessage:[name stringByAppendingString:@" done"]];
	}	
}

- (NSMutableString *)executeFilter:(NSString *)command arguments:(NSMutableArray *)args usestdout:(BOOL)yesorno
{
	CodaTextView	*textView = [controller focusedTextView:self];
	NSString		*result = [self filterTextInput:[self getEditorText] with:command options:args encoding:[textView encoding] useStdout: yesorno];

	if (result == nil) {
		return nil;
	}
	return [NSMutableString stringWithString:result];
}

- (NSString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *dataIn;
	
	@try {
		dataIn = [textInput dataUsingEncoding: anEncoding];
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
		return nil;
	}
	
	NSPipe *toPipe = [NSPipe pipe];
	NSPipe *fromPipe = [NSPipe pipe];
	NSPipe *errPipe = [NSPipe pipe];
	NSFileHandle *writing = [toPipe fileHandleForWriting];
	NSFileHandle *reading;	
	if (useout) {
		reading = [fromPipe fileHandleForReading];
	}
	else {
		reading = [errPipe fileHandleForReading];		
	}

	@try {
		[aTask setStandardInput:toPipe];
		[aTask setStandardOutput:fromPipe];
		[aTask setStandardError:errPipe];
		[aTask setArguments:cmdlineOptions];
	
		[self doLog: [NSString stringWithFormat:@"Executing %@ at path %@ with %@", aTask, launchPath, cmdlineOptions] ];
		
		[aTask setLaunchPath:launchPath];
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData: [reading readDataToEndOfFile] encoding: anEncoding];
		
		[aTask terminate];
		[aTask release];
		return resultData;
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
		return nil;
	}
	@finally {}
	
    return nil;
}

-(void)dealloc
{
	[preferenceController release];
	[messageController release];
	[updateController release];
	[super dealloc];
}

@end