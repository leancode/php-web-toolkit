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
 */

#import "PhpPlugin.h"
#import "CodaPlugInsController.h"
#import "PreferenceController.h"
#import "MessagingController.h"
#import "UpdateController.h"
#import "ValidationResult.h"
#import "RequestController.h"

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
					int lesscssresp = [messageController alertInformation:
									   NSLocalizedString(@"Another plugin is not compatible with the PHP & WebToolkit plugin.\n\nProbably LessCSS or Mojo WebOS.\n\nIf you use the LessCSS plugin: Please uninstall and visit http://incident57.com/less/ to use Less.app instead.",@"")
								additional:NSLocalizedString(@"Click OK to open the Plugins-folder, uninstall the Plugin and restart Coda.\n\nThis message appears only once, but proCSSor is disabled until the conflict is resolved.",@"")
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
									 target:self selector:@selector(doValidatePhp)
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
						  representedObject:nil keyEquivalent:@"$~^v" pluginName:[self name]]; // cmd+alt+ctrl+v
		
		[controller registerActionWithTitle:NSLocalizedString(@"Tidy HTML", @"") underSubmenuWithTitle:@"HTML"
									 target:self selector:@selector(doTidyHtml)
						  representedObject:nil keyEquivalent:@"$~@h" pluginName:[self name]]; // cmd+alt+shift+h
		
		// CSS >>	
		
		[controller registerActionWithTitle:NSLocalizedString(@"Validate CSS online", @"") underSubmenuWithTitle:@"CSS"
									 target:self selector:@selector(doValidateRemoteCss)
						  representedObject:nil keyEquivalent:@"$~^p" pluginName:[self name]]; // cmd+alt+ctrl+p
		
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
		if (![[[NSUserDefaults standardUserDefaults] stringForKey:PrefLastVersionRun] isEqualToString: [self pluginVersionNumber]]) {
			[messageController showInfoMessage:[NSLocalizedString(@"PHP & Web Toolkit updated to ",@"") stringByAppendingString: [self pluginVersionNumber]] 
									additional:NSLocalizedString(@"If you have problems:\nMenu: Plug-Ins > PHP & Web Toolkit > Help\n\n(This message appears only once for each update.)",@"")
										sticky:YES
			 ];
			[[NSUserDefaults standardUserDefaults] setObject:[self pluginVersionNumber] forKey:PrefLastVersionRun];
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

- (void)test
{
	CodaTextView* myView = [controller makeUntitledDocument];
	[myView setSelectedRange:NSMakeRange(0, 0)];
	[myView insertText:@"<?php $a = 1; ?>"];
	[self doValidatePhp];
	[self doValidateHtml];
	[self doValidateRemoteCss];
	[self doValidateRemoteHtml];
	[self doJsMinify];
	[self doJsLint];
	[self doJsTidy];
	[self doProcssorRemote];
	[self doStripPhp];
	[self doTidyCss];
}


- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	SEL action = [aMenuItem action];
	
	if ( ![self editorTextPresent] ) {
		if (action != @selector(showPreferencesWindow) && action != @selector(test) &&  action != @selector(checkForUpdateNow) && action != @selector(goToHelpWebsite) ) {
			return NO;
		}
	}
	return YES;
}

#pragma mark Local Validation

- (void)doValidateHtml
{
	@try {
		[messageController clearResult:self];
		NSMutableArray	*args = [NSMutableArray array];
		
		[args addObject:@"-config"];
		[args addObject:[[myBundle resourcePath] stringByAppendingString:@"/tidy_config_check.txt"]];
		[args addObject:@"--newline"];
		[args addObject:[self currentLineEnding:[controller focusedTextView:self]]];
		[args addObject:[self currentEncoding:[controller focusedTextView:self]]];
		
		ValidationResult *myresult = [self validateWith:[self tidyExecutable] arguments:args called:@"Tidy" showResult:YES];
			
		if ([myresult hasErrorMessage]) {
			[messageController showResult:[NSString stringWithFormat:@"<style type='text/css'>pre{font-family:sans-serif;font-size: 13px;}</style><pre>%@</pre>",[self escapeEntities:[[myresult result] mutableCopy]]]
								   forUrl:@""
								withTitle:NSLocalizedString(@"Tidy validation result",@"")
			 ];
		}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

- (void)doValidatePhp
{
	@try {
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
				[addInfo appendString:NSLocalizedString(@"File was automatically saved.",@"")];
			}
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefPhpBeepOnly]) {
				[[NSSound soundNamed:@"Tink"] play];
			}
			else {
				[messageController showInfoMessage:NSLocalizedString(@"No PHP syntax errors",@"") additional:addInfo];
			}	
		}
		else {
			[messageController alertCriticalError:NSLocalizedString(@"Error parsing PHP - this should not happen",@"")
									   additional:NSLocalizedString(@"Please check the preferences",@"")];
		}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

- (void)doJsLint
{
	@try {
		[messageController clearResult:self];
		if ([[self getEditorText] length] > 65535) {
			[messageController alertCriticalError:@"File is too large - more than 64KB can't be handled currently." additional:@"You can use only a selection or minify the code. This is a know issue currently, sorry."];
			return;
		}

		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								[[myBundle resourcePath] stringByAppendingString:@"/jshint-min.js"],
								@"--",
								[self getEditorText],
								nil];
		ValidationResult *myresult = [self validateWith:
									  @"/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc"
											  arguments:args called:@"JSLint" showResult:YES];
		if ([myresult hasErrorMessage]) {
					[messageController showResult:[
												   [@"<style type='text/css'>body {font-size: 13px; font-family: sans-serif; } h2 {font-size: 19px; } h2.warning { color: blue; } h2.error { color: red; } p { margin-bottom: 0; } p.evidence,pre,code { color:#444; font-family: monospace; background: #f5f5f5; border: 1px solid #ccc; font-size: 12px; margin-top: 2px; margin-left: 4px; padding: 2px 4px; }</style>"
													stringByAppendingString:
														[[NSString alloc] initWithData:
														 [[myresult result] dataUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding]
													]
											autorelease]
								   forUrl:@""
								withTitle:@"JSLint validation result"
			 ];
		}
		// NSMutableArray *args = [NSMutableArray arrayWithObject:[[myBundle resourcePath] stringByAppendingString:@"/jshint-min.js"]]; ValidationResult *myresult = [self validateWith: [[myBundle resourcePath] stringByAppendingString:@"/js-call.sh"] arguments:args called:@"JSLint" showResult:YES];
		// if ([myresult hasErrorMessage]) { [messageController showResult:[myresult result] forUrl:@"" withTitle:@"JSLint validation result" ]; }
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

#pragma mark Remote Validation

- (void)doValidateRemoteHtml
{
	@try {
		[messageController clearResult:self];
		NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [[CssLevel configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefCssLevel]] cmdLineParam], @"profile",
									 @"1", @"ss",
									 @"yes", @"showsource",
									 @"custom", @"ucn_task",
									 @"markup-validator", @"tests",								 
									 nil];
		
		RequestController *myreq = [[[RequestController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefHtmlValidatorUrl]]
									  contents:[[self getEditorText] dataUsingEncoding:NSUTF8StringEncoding]
										fields:args
								   uploadfield:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorParamFile]
									  filename:[[controller focusedTextView:self] path]
									  mimetype:@"text/html"
									  delegate:self 
								  doneSelector:@selector(doValidateRemoteHtmlDone:) errorSelector:@selector(doValidateRemoteHtmlDone:)] autorelease];
		if (!myreq) {}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}
- (void)doValidateRemoteHtmlDone:(id)sender
{
	@try {
		NSString *resultText = [sender serverReply];
		if (resultText == nil || [resultText length] == 0) {
			[messageController alertCriticalError:NSLocalizedString(@"No response from HTML online validator",@"")
									   additional:[NSLocalizedString(@"Make sure you're online and check the Preferences.\n\nError: ",@"") stringByAppendingString:[sender errorReply]]
			 ];
		}
		else {
			[messageController showResult:[self improveWebOutput:resultText fromDomain:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]] 
								   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]
								withTitle:[NSLocalizedString(@"HTML validation result via ",@"") stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]]
			 ];
		}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

- (void)doValidateRemoteCss
{
	@try {
		[messageController clearResult:self];
		NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [[CssLevel configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefCssLevel]] cmdLineParam], @"profile",
									 nil];
		
		RequestController *myreq = [[[RequestController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefCssValidatorUrl]]
									  contents:[[self getEditorText] dataUsingEncoding:NSUTF8StringEncoding]
										fields:args
								   uploadfield:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorParamFile]
									  filename:[[controller focusedTextView:self] path]
									  mimetype:@"text/css"
									  delegate:self 
								  doneSelector:@selector(doValidateRemoteCssDone:) errorSelector:@selector(doValidateRemoteCssDone:)] autorelease];
		if (!myreq) {}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}
- (void)doValidateRemoteCssDone:(id)sender
{
	@try {
		NSString *resultText = [sender serverReply];
		if (resultText == nil || [resultText length] == 0) {
			[messageController alertCriticalError:NSLocalizedString(@"No response from CSS online validator",@"")
									   additional:[NSLocalizedString(@"Make sure you're online and check the Preferences.\n\nError: ",@"") stringByAppendingString:[sender errorReply]]
			 ];
		}
		else {
			[messageController showResult:[self improveWebOutput:resultText fromDomain:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]] 
								   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]
								withTitle:[NSLocalizedString(@"CSS validation result via ",@"") stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefCssValidatorUrl]]
			 ];
		}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

#pragma mark Tidy HTML/CSS/PHP

-(void)doTidyHtml
{
	@try {
		NSString *myConfig = [[HtmlTidyConfig configForIndex: [[NSUserDefaults standardUserDefaults] integerForKey:PrefHtmlTidyConfig]] cmdLineParam];
		NSString *configFile = [[myBundle resourcePath] stringByAppendingString:[[@"/tidy_config_format_" stringByAppendingString:myConfig] stringByAppendingString:@".txt"]];
	
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-config", configFile, @"--newline", [self currentLineEnding:[controller focusedTextView:self]], [self currentEncoding:[controller focusedTextView:self]], nil];
		[self reformatWith:[self tidyExecutable] arguments:args called:@"tidy"];
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

-(void)doTidyCss
{
	@try {
		NSString *myConfig = [[CssTidyConfig configForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:PrefCssTidyConfig]] cmdLineParam];
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-t", myConfig, @"-l", [self currentLineEnding:[controller focusedTextView:self]], nil];
		[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/csstidy.php"] arguments:args called:@"CSSTidy"];
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

- (void)doStripPhp
{
	@try {
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-n", @"-w", @"--", nil];	
		[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"PHP Strip"];
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doTidyPhp
{
	@try {	
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
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doProcssorRemote
{
	@try {
		NSMutableDictionary *args = [NSMutableDictionary dictionary];

		[args setObject:@"file" forKey:@"source"];
		if (![[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSafe] isEqualToString:@"1"] ) {
			[args setObject:[[CssProcssor configForIntvalueSorting:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcSort]] cmdLineParam]
					 forKey:@"sort_declarations"];
			
			if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcGrouping] != nil) {
				[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcGrouping] forKey:@"grouping"];
			}
		}
		if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcSafe] != nil) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSafe] forKey:@"safe"];
		}
		if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules] != nil) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules] forKey:@"indent_rules"];
		}
		
		if ([[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcIndentRules] isEqualToString:@"1"] ) {
			//	[args setObject:[[CssProcssor configForIntvalueIndentLevels:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcIndentLevel]] cmdLineParam] forKey:@"indent_level"];
			[args setObject:@"space" forKey:@"indent_type"];
		}
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcColumnize] isEqualToString:@"1"] ) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcColumnize] forKey:@"tabbing"];
			[args setObject:[[CssProcssor configForIntvalueAlignment:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcAlignment]] cmdLineParam]
					 forKey:@"alignment"];
		}
		
		[args setObject:[[CssProcssor configForIntvalueFormatting:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcFormatting]] cmdLineParam]
				 forKey:@"property_formatting"];
		[args setObject:[[CssProcssor configForIntvalueBraces:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcBraces]] cmdLineParam]
				 forKey:@"braces"];
		[args setObject:[[CssProcssor configForIntvalueIndentSize:[[NSUserDefaults standardUserDefaults] integerForKey:PrefProcIndentSize]] cmdLineParam]
				 forKey:@"indent_size"];
		
		if ([[NSUserDefaults standardUserDefaults] stringForKey:PrefProcSelectorsSame] != nil) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcSelectorsSame] forKey:@"selectors_on_same_line"];
		}
		
		if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcBlankLine] != nil) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcBlankLine] forKey:@"blank_line_rules"];
		}
		
		if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefProcDocblock] != nil) {
			[args setObject:[[NSUserDefaults standardUserDefaults] stringForKey: PrefProcDocblock] forKey:@"docblock"];
		}
		
		RequestController *myreq = [[[RequestController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefProCSSorUrl]]
						 contents:[[self getEditorText] dataUsingEncoding:NSUTF8StringEncoding]
						   fields:args
					  uploadfield:@"css" 
						 filename:@"my.css" 
						 mimetype:@"text/css"
						 delegate:self 
					 doneSelector:@selector(doProcssorRemoteDone:) errorSelector:@selector(doProcssorRemoteDone:)]
									autorelease];
									
		if (!myreq) {}
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doProcssorRemoteDone:(id)sender
{
	@try {
		NSString *resultText = [sender serverReply];
		if (resultText == nil || [resultText length] == 0) {
			[messageController alertCriticalError:NSLocalizedString(@"No response from proCSSor.com",@"")
									   additional:[NSLocalizedString(@"Make sure you're online, check the Preferences.\n\nError:\n",@"") stringByAppendingString:[sender errorReply]]];
		}
		else {
			NSError *error;
			SBJsonParser *json = [SBJsonParser alloc];
			
			if (![json respondsToSelector:@selector(objectWithString:error:)] ) {
				[messageController alertCriticalError:NSLocalizedString(@"Sorry - an incompatible plug-in was found.\n\nPlease remove this plugin first." ,@"")
										   additional:NSLocalizedString(@"Remove the LessCSS-plugin or WebMojo-plugin if present or report a bug on www.chipwreck.de",@"")];
			}
			else {
				NSMutableDictionary *jsonResult = [json objectWithString:resultText error:&error];
				if (jsonResult == nil) {
					[json release];
					[messageController alertCriticalError:NSLocalizedString(@"Invalid response from proCSSor received.",@"") 
											   additional:[error localizedDescription]];
					return;
				}
				NSString *cssResult = [jsonResult objectForKey:@"css"];
				if (cssResult == nil || [cssResult length] == 0) {
					[json release];
					[messageController alertCriticalError:NSLocalizedString(@"No CSS received, make sure the CSS file is valid" ,@"")
																			additional:NSLocalizedString(@"Error: No JSON object called 'css' from proCSSor received",@"")];
					return;
				}		
				
				[self replaceEditorTextWith:cssResult];
				[messageController showInfoMessage:@"proCSSor done"];
			}
			[json release];
		}
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doJsTidy
{
	if ([[self getEditorText] length] > 65535) {
		[messageController alertCriticalError:@"File is too large - more than 64KB can't be handled currently." additional:@"You can use only a selection or minify the code. This is a know issue currently, sorry."];
		return;
	}
	
	@try {
		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								[[myBundle resourcePath] stringByAppendingString:@"/jstidy-min.js"],
								@"--",
								[self getEditorText],
								nil];
		[self reformatWith:@"/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc" arguments:args called:@"JSTidy"];
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
	// NSMutableArray *args = [NSMutableArray arrayWithObject:[[myBundle resourcePath] stringByAppendingString:@"/jstidy-min.js"]]; [self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/js-call.sh"] arguments:args called:@"JSTidy"];	
}

- (void)doJsMinify
{
	@try {
		[self reformatWith:[[myBundle resourcePath] stringByAppendingString:@"/jsminify.php"] arguments:[NSMutableArray array] called:@"JSMinify"];
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

#pragma mark Updates

- (void)checkForUpdateNow
{
	int avail = [updateController isUpdateAvailable];
	if (avail == 1) {
		int res = [messageController alertInformation:@"An update for PHP & Web Toolkit is available!\nClick OK to download. (Restart Coda after installing)"
										   additional:@"You can enable automatic checking for updates in Preferences." cancelButton:YES];
		if (res == 1) {
			[self downloadUpdate:nil];
		}
	}
	else if (avail == 0) {
		[messageController showInfoMessage:NSLocalizedString(@"No update available",@"")
								additional:NSLocalizedString(@"You can enable automatic checking for updates in Preferences.",@"")];
	}
	else if (avail == 3) {
		[messageController alertCriticalError:NSLocalizedString(@"Could not check for updates, please make sure you're connected to the internet or try again later.",@"")
								additional:NSLocalizedString(@"You can disable the automatic check in the preferences.",@"")];
	}
}

- (void)showUpdateAvailable
{
	int res = [messageController alertInformation:NSLocalizedString(@"An update for PHP & Web Toolkit is available!\nClick OK to download in your browser.",@"")
									   additional:NSLocalizedString(@"You can disable automatic checking for updates in Preferences.",@"")
									 cancelButton:YES];
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
				[messageController alertCriticalError:NSLocalizedString(@"Could not execute goToLine()",@"") additional:NSLocalizedString(@"Please use Mac or Unix line endings if possible",@"")];
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
	@catch (NSException *e) {
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

- (void)replaceEditorTextWith:(NSString *)newText
{
	CodaTextView *textView = [controller focusedTextView:self];
	
	if (newText == nil || [newText length] < 1) {
		[messageController alertCriticalError:NSLocalizedString(@"No new text received in replaceEditorTextWith.",@"")
								   additional:NSLocalizedString(@"This should not happen, please report a bug at www.chipwreck.de",@"")];
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

	BOOL usesstdout = YES;
	if ([name isEqualToString:@"Tidy"]) {
		usesstdout = NO;
	}
	NSMutableString *resultText = [self executeFilter:command arguments:args usestdout:usesstdout];
	[myResult setResult:resultText];
	
	if (resultText == nil || [resultText length] == 0) {
		[messageController alertCriticalError:[name stringByAppendingString:NSLocalizedString(@" returned nothing",@"")] additional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"")];
	}
	else {
		if ([resultText rangeOfString:@"No warnings or errors were found"].location != NSNotFound || [resultText rangeOfString:@"No syntax errors detected"].location != NSNotFound) {
			[myResult setValid:YES];
		}
	}
	
	if (show && [myResult valid]) {
		[messageController showInfoMessage:[name stringByAppendingString:NSLocalizedString(@": No errors",@"")] additional:resultText];
	}

	return [myResult autorelease];
}


- (void)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name
{
	NSMutableString *resultText = [self executeFilter:command arguments:args usestdout:YES];
	
	if (resultText == nil || [resultText length] < 6) {
		[messageController alertCriticalError:[name stringByAppendingString:NSLocalizedString(@" returned nothing",@"")] additional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"")];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"\nFatal"]) {
		[messageController alertCriticalError:[name stringByAppendingString:NSLocalizedString(@" exception received.",@"")] additional:[NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.\n\n",@"") stringByAppendingString: resultText]];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"!ERROR"]) {
		[messageController alertCriticalError:[name stringByAppendingFormat:@": %@",[resultText substringFromIndex:1]] additional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"")];
	}
	else {
		if ([name isEqualToString:@"JSTidy"]) {
			[self replaceEditorTextWith:
			 [[NSString alloc] initWithData:[resultText dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES] encoding:[[controller focusedTextView:self] encoding]]
			 ];
		}
		else {
			[self replaceEditorTextWith:resultText];
		}		
		
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
		[aTask setLaunchPath:launchPath];
	
		[self doLog: [NSString stringWithFormat:@"Executing %@ at path %@ with %@", aTask, launchPath, cmdlineOptions] ];
		
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData: [reading readDataToEndOfFile] encoding: anEncoding];
		
		[aTask terminate];
		[aTask release];
//		[self doLog: [NSString stringWithFormat:@"Returned %@", resultData] ];
		
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