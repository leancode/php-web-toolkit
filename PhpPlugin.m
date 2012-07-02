//
//  PhpPlugin.m
//  PhpPlugin
//
//  Created by Mario Fischer on 23.12.08.
//  Copyright 2008-2011 chipwreck.de. All rights reserved.

/*
csslint. maybe?:
 https://github.com/stubbornella/csslint
 http://www.nczonline.net/blog/2011/08/18/css-lint-updated-to-0-5-0/?
 
jshint setting defaults:
+ browser    : true, // if the standard browser globals should be predefined
+ debug      : true, // if debugger statements should be allowed
+ devel      : true, // if logging should be allowed (console, alert, etc.)
+ jquery     : true, // if jQuery globals should be predefined
+ laxbreak   : true, // if line breaks should not be checked
+ mootools    : true, // if MooTools globals should be predefined 
+ node        : FALSE, // if the Node.js environment globals should be predefined !!REMOVED!!
+ prototypejs : true, // if Prototype and Scriptaculous globals should be predefined
 
jshint settings not used:
- passfail   : true, // if the scan should stop on first error

jshint no idea yet...
? couch       : true, // if CouchDB globals should be predefined
? es5         : true, // if ES5 syntax should be allowed
? rhino       : true, // if the Rhino environment globals should be predefined
? expr        : true, // if ExpressionStatement should be allowed as Programs
? supernew    : true, // if `new function () { ... };` and `new Object;` should be tolerated
 */

#import "PhpPlugin.h"
#import "CodaPlugInsController.h"
#import "PreferenceController.h"
#import "MessagingController.h"
#import "DownloadController.h"
#import "UpdateController.h"
#import "ValidationResult.h"
#import "HtmlValidationConfig.h"
#import "RequestController.h"

@implementation PhpPlugin

#pragma mark Required Coda Plugin Methods

// Support for Coda 2.0 and lower

- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle
{
    return [self initWithController:aController plugInBundle:(NSObject <CodaPlugInBundle> *)yourBundle];
}

// Support for Coda 2.0.1 and higher
// NOTE: must set the CodaPlugInSupportedAPIVersion key to 6 or above to use this init method

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
	return [self initWithController:aController plugInBundle:plugInBundle];
}

- (id)initWithController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
    if ( (self = [super init]) != nil )
    {
		// init controllers
		preferenceController = [[PreferenceController alloc] init];
		[preferenceController setBundlePath:[plugInBundle resourcePath]];
		[preferenceController setMyPlugin:self];
		
		messageController = [[MessagingController alloc] init];
		[messageController setBundlePath:[plugInBundle resourcePath]];
		[messageController setMyPlugin:self];
		
		updateController = [[UpdateController alloc] init];
		[updateController setMyPlugin:self];
		
		downloadController = [[DownloadController alloc] init];
		[downloadController setMyPlugin:self];
				
		// init vars
		controller = aController;
		myBundle = plugInBundle;
		
		NSLog(@"Starting Coda PHPPlugin, version: %@ - report bugs at http://www.chipwreck.de", [self pluginVersionNumber]);
		
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
	
		[controller registerActionWithTitle:NSLocalizedString(@"Minify CSS", @"") underSubmenuWithTitle:@"CSS"
									 target:self selector:@selector(doJsMinify)
						  representedObject:nil keyEquivalent:@"$^@m" pluginName:[self name]]; // alt+shift+t
		
		// JS >>
		[controller registerActionWithTitle:NSLocalizedString(@"JS Hint", @"") underSubmenuWithTitle:@"JS"
									 target:self selector:@selector(doJsLint)
						  representedObject:nil keyEquivalent:@"$~@j" pluginName:[self name]]; // cmd+alt+shift+j
		
		[controller registerActionWithTitle:NSLocalizedString(@"Minify Javascript", @"") underSubmenuWithTitle:@"JS"
									 target:self selector:@selector(doJsMinify)
						  representedObject:nil keyEquivalent:@"$~@m" pluginName:[self name]]; // cmd+alt+shift+m
		
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
		
		[self sanityCheck]; // check for duplicate/incompatible plugins
				
		// startup msg
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

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	@try {
		SEL action = [aMenuItem action];
		
		if (action != @selector(showPreferencesWindow) && action != @selector(checkForUpdateNow) && action != @selector(goToHelpWebsite) && action != @selector(testUpdatePlugin) && action != @selector(showPluginResources)) {
			if ( ![self editorTextPresent] ) {
				return NO;
			}
		}
		return YES;
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
		return NO;
	}
}

- (void)textViewWillSave:(CodaTextView*)textView /* Coda 2 only */
{
	NSString *exts = [[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpExtensions];
	if (exts == nil) {
		return;
	}
	NSArray *extsArray = [exts componentsSeparatedByCharactersInSet:
						  [NSCharacterSet characterSetWithCharactersInString:@", "] // NSString *trimmedString = [dirtyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						];
	if (extsArray == nil) {
		return;
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefPhpOnSave]) {
		BOOL doValidate = NO;
		for (NSString *anextension in extsArray) {
			if (anextension != nil && ![anextension isEqualToString:@""]) {
				if ([[textView path] hasSuffix:anextension]) {
					[self doLog:[NSString stringWithFormat:@"File has extension: %@", anextension]];
					doValidate = YES;
				}
			}
		}
		if (!doValidate) {
			return;
		}
		
		ValidationResult *myresult = [self validatePhp];
		
		if ([myresult hasFailResult]) {
			[self showPhpError:myresult];
		}
	}
}

- (NSString*)willPublishFileAtPath:(NSString*)inputPath /* Coda 2 only */
{
	if (
		([[NSUserDefaults standardUserDefaults] boolForKey:PrefCssMinifyOnPublish] && [[[controller focusedTextView:self] path] hasSuffix:@"css"])
		||
		([[NSUserDefaults standardUserDefaults] boolForKey:PrefJsMinifyOnPublish] && [[[controller focusedTextView:self] path] hasSuffix:@"js"])
		) {
		return [self minifyFileOnDisk:inputPath];
	}
	return inputPath;
}

- (NSString*)minifyFileOnDisk:(NSString*)inputPath
{
	[self doLog:[NSString stringWithFormat:@"Minify file in: %@", inputPath]];
	
	NSString *tmpFileName = [NSString stringWithFormat:@"minify-%.0f-%i.tmp", [[NSDate date] timeIntervalSince1970], (arc4random() % 99999999)];
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
	
	NSError *error;
	NSString *inputText = [[NSString alloc] initWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:&error];
	if (inputText == nil) {
		[messageController alertCriticalError:[NSString stringWithFormat:@"Error readinig minified at %@\n%@", inputPath, [error localizedFailureReason]] additional:@""];
		return inputPath;
	}
	
	[self doLog:[NSString stringWithFormat:@"Minify file out: %@", tmpPath]];
	
	NSMutableArray *args = [NSMutableArray arrayWithObjects:[self currentLineEnding], nil];
	NSMutableString *resultText = [self filterTextInput:inputText with:[[myBundle resourcePath] stringByAppendingString:@"/jsminify.php"] options:args encoding:[[controller focusedTextView:self] encoding] useStdout:YES];
	BOOL ok = [resultText writeToFile:tmpPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
	[inputText release];
	if (!ok) {
		[messageController alertCriticalError:[NSString stringWithFormat:@"Error writing minified file at %@\n%@", tmpPath, [error localizedFailureReason]] additional:@""];
		return inputPath;
	}
	
	return tmpPath;	
}

#pragma mark Local Validation

- (void)doValidateHtml
{
	@try {
		[messageController clearResult:self];
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-config", [[myBundle resourcePath] stringByAppendingString:@"/tidy_config_check.txt"],
								@"--newline", [self currentLineEnding], [self currentEncoding], nil];
		
		ValidationResult *myresult = [self validateWith:[self tidyExecutable] arguments:args called:@"Tidy" showResult:YES useStdOut:NO];
			
		if ([myresult hasFailResult]) {
			[messageController showResult:[HtmlTidyConfig parseTidyOutput:[myresult result]]
								   forUrl:@""
								withTitle:[@"Tidy validation result for " stringByAppendingString:[self currentFilename]]
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
		ValidationResult *myresult = [self validatePhp];

		if ([myresult hasFailResult]) {
			[self showPhpError:myresult];
		}
		else if ([myresult valid]) {
			NSMutableString *addInfo = [NSMutableString stringWithString:[@"File: " stringByAppendingString:[self currentFilename]]];
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefAutoSave]) {
				[[controller focusedTextView:self] save];
				[addInfo appendString:NSLocalizedString(@"\nFile was automatically saved.",@"")];
			}
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefPhpBeepOnly]) {
				[[NSSound soundNamed:@"Tink"] play];
			}
			else {
				[messageController showInfoMessage:NSLocalizedString(@"No PHP syntax errors",@"") additional:addInfo];
			}	
		}
		else {
			NSBeep();
			[self doLog:@"Error validating PHP - no result received"];
		}
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

- (ValidationResult*)validatePhp
{
	NSMutableArray	*args = [NSMutableArray arrayWithObjects:@"-n", @"-l", @"--", nil];
	return [self validateWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"PHP" showResult:NO useStdOut:YES];
}

- (void)showPhpError:(ValidationResult*)myresult
{
	NSBeep();
	int lineOfError = 0;
	NSScanner *scanner = [NSScanner scannerWithString:[myresult result]];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
	[scanner scanInt: &lineOfError];
	
	[messageController openSheetPhpError:[[myresult result] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] atLine:lineOfError forWindow:[[controller focusedTextView:self] window]];
}

- (void)doJsLint
{
	@try {
		[messageController clearResult:self];
		if ([[self getEditorText] length] > maxLengthJs) {
			[messageController alertInformation:@"File is too large: More than 64KB can't be handled currently." additional:@"You can use only a selection or minify the code. This is a known issue currently, sorry." cancelButton:NO];
			return;
		}
		NSMutableString* options = [NSMutableString stringWithString:@"browser,debug,devel,jquery,laxbreak,mootools,prototypejs,"]; // node removed
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintBitwise]) {
			[options appendString:@"bitwise,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintNewcap]) {
			[options appendString:@"newcap,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintNoempty]) {
			[options appendString:@"noempty,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintNomen]) {
			[options appendString:@"nomen,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintOnevar]) {
			[options appendString:@"onevar,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintPlusplus]) {
			[options appendString:@"plusplus,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintRegexp]) {
			[options appendString:@"regexp,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintUndef]) {
			[options appendString:@"undef,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintWhite]) {
			[options appendString:@"white,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintAsi]) {
			[options appendString:@"asi,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintCurly]) {
			[options appendString:@"curly,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintEqeqeq]) {
			[options appendString:@"eqeqeq,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintEvil]) {
			[options appendString:@"evil,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintForin]) {
			[options appendString:@"forin,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintImmed]) {
			[options appendString:@"immed,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintLoopfunc]) {
			[options appendString:@"loopfunc,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintStrict]) {
			[options appendString:@"strict,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintSub]) {
			[options appendString:@"sub,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintEqnull]) {
			[options appendString:@"eqnull,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintNoarg]) {
			[options appendString:@"noarg,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintNonew]) {
			[options appendString:@"nonew,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintBoss]) {
			[options appendString:@"boss,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintShadow]) {
			[options appendString:@"shadow,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintLatedef]) {
			[options appendString:@"latedef,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintGlobalstrict]) {
			[options appendString:@"globalstrict,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSHintSmartTabs]) {
			[options appendString:@"smarttabs,"];
		}
		
		NSMutableArray *args = [NSMutableArray arrayWithObjects:[[myBundle resourcePath] stringByAppendingString:@"/jshint-min.js"], options, [self currentLineEnding], nil];
		ValidationResult *myresult = [self validateWith:[[myBundle resourcePath] stringByAppendingString:@"/js-call.sh"] arguments:args called:@"JSHint" showResult:YES useStdOut:YES];
	
		if ([myresult hasFailResult]) {
			[messageController showResult:
			 [[MessagingController getCssForJsLint] stringByAppendingString:[myresult result]]
									forUrl:@""
								withTitle:[@"JSHint validation result for " stringByAppendingString:[self currentFilename]]];			
		}
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
									 @"json", @"out",
									 @"custom", @"ucn_task",
									 @"markup-validator", @"tests",								 
									 nil];
		
		RequestController *myreq = [[[RequestController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefHtmlValidatorUrl]]
									  contents:[[self getEditorText] dataUsingEncoding:NSUTF8StringEncoding]
										fields:args
								   uploadfield:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorParamFile]
									  filename:[self currentFilename]
									  mimetype:@"text/html"
									  delegate:self 
								  doneSelector:@selector(doValidateRemoteHtmlDone:) errorSelector:@selector(doValidateRemoteHtmlDone:)] autorelease];
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
			NSError *error;
			SBJsonParser *json = [SBJsonParser alloc];			
			if (![json respondsToSelector:@selector(objectWithString:error:)] ) {
				[messageController alertCriticalError:NSLocalizedString(@"Sorry - an incompatible plug-in was found.\n\nPlease remove this plugin first." ,@"")
										   additional:NSLocalizedString(@"Remove the LessCSS-plugin or WebMojo-plugin if present or report a bug on www.chipwreck.de",@"")];
			}
			else {
				NSMutableDictionary *jsonResult = [json objectWithString:resultText error:&error];
				[json release];
				json = nil;
				
				NSMutableString *resultFromJson = [HtmlValidationConfig parseValidatorNuOutput:jsonResult];
				if (resultFromJson != nil && [resultFromJson length] > 0) {
					[messageController showResult:[[MessagingController getCssforValidatorNu] stringByAppendingString:resultFromJson]
										   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]
										withTitle:[NSLocalizedString(@"HTML validation result via ",@"") stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]]];
				}
				else {
					[messageController showResult:[self improveWebOutput:resultText fromDomain:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]] 
								   forUrl:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]
								withTitle:[NSLocalizedString(@"HTML validation result via ",@"") stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlValidatorUrl]]];
				}
			}
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
									  filename:[self currentFilename]
									  mimetype:@"text/css"
									  delegate:self 
								  doneSelector:@selector(doValidateRemoteCssDone:) errorSelector:@selector(doValidateRemoteCssDone:)] autorelease];
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
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-config", [[myBundle resourcePath] stringByAppendingString:[[@"/tidy_config_format_" stringByAppendingString:myConfig] stringByAppendingString:@".txt"]], 
								@"--newline", [self currentLineEnding], [self currentEncoding], nil];
		[self reformatWith:[self tidyExecutable] arguments:args called:@"Tidy"];
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

-(void)doTidyCss
{
	@try {
		if ([[self currentEncoding] isEqualToString:@"-utf16"]) {
			[messageController alertInformation:@"CSS files in UTF-16 aren't supported" additional:@"Convert the CSS file to UTF-8 in order to process it." cancelButton:NO];
			return;
		}
		NSString *prefJs;
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefCssTidyRemoveLast]) {
			prefJs = @"1";
		}
		else {
			prefJs = @"0";			
		}
		
		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								@"-n",
								@"-f",
								[[myBundle resourcePath] stringByAppendingString:@"/csstidy.php"],
								@"--",
								@"-t", [[CssTidyConfig configForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:PrefCssTidyConfig]] cmdLineParam],
								@"-l", [self currentLineEnding], 
								@"-last", prefJs, 
								nil];
		[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"CSSTidy"];
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
		ValidationResult *myresult = [self validatePhp];
		
		if ([myresult hasFailResult]) {
			[self showPhpError:myresult];
			return;
		}
		
		NSMutableArray *args = [NSMutableArray arrayWithObjects:@"-n", @"-f", [[myBundle resourcePath] stringByAppendingString:@"/phptidy-coda.php"], @"--", nil];
		
		[args addObject:@"-l"];
		[args addObject: [self currentLineEnding]];
		
		int myPhpTidyBracesConfigIdx = [[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyBraces];
		
		[args addObject:@"-b"];
		[args addObject:[[PhpTidyConfig configForIndex: myPhpTidyBracesConfigIdx] cmdLineParam]];
		
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
		
		[args addObject:@"-p"];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyReplacePhpTags] == 1) {
			[args addObject:@"1"];
		}
		else {
			[args addObject:@"0"]; 		 
		}
		
		[args addObject:@"-i"];
		if ([[controller focusedTextView:self] usesTabs]) {
			[args addObject:@"t"];
		}
		else {
			int tw = [[controller focusedTextView:self] tabWidth];
			[args addObject:[@"s" stringByAppendingString:[NSString stringWithFormat:@"%i", tw]]];
		}
		
		[args addObject:@"-r"];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:PrefPhpTidyReplaceShellComments] == 1) {
			[args addObject:@"1"];
		}
		else {
			[args addObject:@"0"]; 		 
		}
			
		[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"PHPTidy"];
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doJsTidy
{
	@try {
		NSMutableString* options = [NSMutableString stringWithString:@""];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSTidyBracesOnOwnLine]) {
			[options appendString:@"braces_on_own_line,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSTidyPreserveNewlines]) {
			[options appendString:@"preserve_newlines,"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefJSTidySpaceAfterAnonFunction]) {
			[options appendString:@"space_after_anon_function,"];
		}
		if ([[controller focusedTextView:self] usesTabs]) {
			[options appendString:@"indent_char_tab,"];
		}
		else {
			[options appendString:@"indent_char_space,"];
		}
		
		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								@"-n",
								@"-f",
								[[myBundle resourcePath] stringByAppendingString:@"/jsbeautifier.php"],
								@"--",
								options, [self currentLineEnding], nil];
		
		[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"JSTidy"];
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
}

- (void)doJsMinify
{
	@try {
		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								@"-n",
								@"-f",
								[[myBundle resourcePath] stringByAppendingString:@"/jsminify.php"],
								@"--",
								[self currentLineEnding], nil];		
		
		[self reformatWith:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] arguments:args called:@"JSMinify"];
	}
	@catch (NSException *e) {	
		[messageController alertCriticalException:e];
	}
}

#pragma mark Updates

- (void)testUpdatePlugin
{
	[downloadController showPanelWithUrl:[updateController testDownloadUrl]];
}

- (void)checkForUpdateNow
{
	int avail = [updateController isUpdateAvailable];
	if (avail == 1) {
		[downloadController showPanelWithUrl:[updateController directDownloadUrl]];
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
	[downloadController showPanelWithUrl:[updateController directDownloadUrl]];
}

- (void)downloadUpdateWeb
{
	[updateController downloadUpdate:nil];
}


#pragma mark Helper methods

- (NSString *)improveWebOutput:(NSString *)input fromDomain:(NSString *)domain // Hacked stuff..improve w3c output with absolute links DON'T ASK!
{
	if (input == nil) return @"";
	
	NSString *baseDomain = [[domain stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
	return [
			[
			 [input
			  stringByReplacingOccurrencesOfString:@"src=\"images/" withString: [[@"src=\"" stringByAppendingString: baseDomain] stringByAppendingString:@"images/"] ]
			 stringByReplacingOccurrencesOfString:@"@import \"./style/" withString: [[@"@import \"" stringByAppendingString: baseDomain] stringByAppendingString:@"style/"] ]
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

- (void)showPluginResources
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [myBundle resourcePath]]];
}

- (void)doLog:(NSString *)loggable
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefDebugMode])  {
		if ([loggable length] > PrefMaxLogLen) {
			NSLog(@"[Coda PHP Toolkit] %@ [...]", [loggable substringToIndex:PrefMaxLogLen]);
		}
		else {
			NSLog(@"[Coda PHP Toolkit] %@", loggable);
		}
	}	
}

- (BOOL)isCoda2
{
	return ([controller apiVersion] >= 6);
}

- (void)sanityCheck
{
	// check sbjson
	if (![[NSUserDefaults standardUserDefaults] integerForKey:PrefMsgShown]) {
		@try {
			SBJsonParser *json = [SBJsonParser alloc];
			if (![json respondsToSelector:@selector(objectWithString:error:)]) {
				int lesscssresp = [messageController alertInformation:
								   NSLocalizedString(@"Another plugin is not compatible with the PHP & WebToolkit plugin.\n\nProbably LessCSS or Mojo WebOS.\n\nIf you use the LessCSS plugin: Please uninstall and visit http://incident57.com/less/ to use Less.app instead.",@"")
														   additional:NSLocalizedString(@"Click OK to open the Plugins-folder, uninstall the Plugin and restart Coda.\n\nThis message appears only once.",@"")
														 cancelButton:YES];
				
				if (lesscssresp == 1) {
					NSString *lesscsspath = [[[myBundle bundlePath] stringByDeletingLastPathComponent] stringByExpandingTildeInPath];
					[[NSWorkspace sharedWorkspace] selectFile:[lesscsspath stringByAppendingString:@"/LessCSS.codaplugin"] inFileViewerRootedAtPath:lesscsspath];
					[[NSWorkspace sharedWorkspace] selectFile:[lesscsspath stringByAppendingString:@"/MojoPlugin.codaplugin"] inFileViewerRootedAtPath:lesscsspath];
				}
				
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:PrefMsgShown];
			}
		}
		@catch (NSException *e) {
			[messageController alertCriticalException:e];
		}
	}
	
	// check duplicate plugins
	@try {
		NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
		NSError *error = nil;
		[self doLog:[@"Checking for duplicate plugins in: " stringByAppendingString:[self codaPluginPath]]];
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self codaPluginPath] error: &error];
		int numPlugins = 0;
		for (NSString *filename in dirContents) {
			if ([filename hasPrefix:@"PhpPlugin"] && [filename hasSuffix:@"codaplugin"]) {
				[self doLog:[@"FOUND: " stringByAppendingString:filename]];
				numPlugins++;
			}
		}
		if (numPlugins > 1) {
			int plugindupresp = [messageController alertInformation:
								 NSLocalizedString(@"You have installed PHP & Web Toolkit more than once.",@"")
														 additional:NSLocalizedString(@"Click OK to open the Plugins-folder, delete additional files starting with 'PHPPlugin' restart Coda.\n\n\nThis message might appear more than once.",@"")
														thirdButton:@"Help"];
			
			if (plugindupresp == 1) {
				[[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [self codaPluginPath]]]; 
			}
			else if (plugindupresp == 3) {
				[self goToHelpWebsite];
			}
		}
	}
	@catch (NSException *e) {
		[messageController alertCriticalException:e];
	}
	
	// check growl
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUseGrowl]) {
		if ([self growlVersion] == nil) {
			[self doLog:@"No growl version found, disabling growl notifications"];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:PrefUseGrowl];
		}
		else {
			[self doLog:[@"Found growl version: " stringByAppendingString: [self growlVersion]]];
		}
	}	
}

#pragma mark Editor actions

- (void)displayHtmlString:(NSString*)data
{
	[controller displayHTMLString:data];
}

- (void)goToLine:(int)lineNumber
{
	CodaTextView *textView = [controller focusedTextView:self];
	
	if ([self isCoda2]) {
		[textView goToLine:lineNumber column:0];
		return;
	}	
	
	unsigned numCharsInLine = 0;
	unsigned pos = 0;
	unsigned numIterations = 0;
	int currLineNumber = 0;
	int prevLineNumber = -1;
	int charsForLE = 1;
	
	[textView setSelectedRange: NSMakeRange(0, 0)];
	if ([[textView lineEnding] isEqualToString:@"\r\n"]) {
		charsForLE = 2;
	}
	
	@try {
		while (true) {
			currLineNumber = [textView currentLineNumber];
			if (prevLineNumber == currLineNumber && numIterations > 10) {
				[messageController alertCriticalError:NSLocalizedString(@"Could not execute goToLine()",@"") additional:NSLocalizedString(@"Please report this error",@"")];
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

- (BOOL)editorSelectionPresent /* Selection desired and present? */
{
	CodaTextView *textView = [controller focusedTextView:self];
	return ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUseSelection] && [textView selectedText] != nil && [[textView selectedText] length] > PrefMinSelectionLen);
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
	
	if (newText == nil || [newText length] == 0) {
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

- (NSString *)currentFilename
{
	if ([[[controller focusedTextView:self] window] title] != nil) {
		if ([[controller focusedTextView:self] siteNickname] != nil) {
			return [[[[controller focusedTextView:self] window] title] stringByReplacingOccurrencesOfString:
					[@" - " stringByAppendingString:[[controller focusedTextView:self] siteNickname]] withString:@""];
		}
		return [[[controller focusedTextView:self] window] title];
	}
	return @"(untitled)";
}

- (NSString *)currentLineEnding /* Get current line ending as string (CR, LF, CRLF) */
{
	if ([[[controller focusedTextView:self] lineEnding] isEqualToString:@"\r\n"]) {
		return @"CRLF";
	}
	if ([[[controller focusedTextView:self] lineEnding] isEqualToString:@"\n"]) {
		return @"LF";
	}
	return @"CR";
}

- (NSString *)currentEncoding /* Get current encoding as string (utf8, macroman,..) */
{
	Encoding *encodingObj = [Encoding encodingForIntvalue:[[controller focusedTextView:self] encoding]];
	if (encodingObj.cmdLineParam != nil) {
		return encodingObj.cmdLineParam;
	}
	return nil;
}

#pragma mark Information getters

- (NSString *)codaPluginPath
{
	return [[myBundle bundlePath] stringByDeletingLastPathComponent];	
}

- (NSString *)pluginVersionNumber
{
	return [[myBundle infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)pluginIconPath
{
	return [[myBundle resourcePath] stringByAppendingString:@"/codaphp-plugin-icon.png"];
}

- (NSString *)phpVersion
{
	NSMutableArray *args = [NSMutableArray arrayWithObject:@"-v"];
	
	NSString *result = [self filterTextInput:@"" with:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal] options:args encoding:NSUTF8StringEncoding useStdout:YES];
	if (result != nil) {
		return result;
	}
	else {
		return @"ERROR - php not found";
	}
}

- (NSString *)tidyExecutable
{
	return [[myBundle resourcePath] stringByAppendingString:@"/tidy"];
}

- (NSString *)jscInterpreter
{
	return @"/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc";
}

- (NSString *)growlNotify
{
	if ([[self growlVersion] isEqualToString:@"1.2"]) {
		return [[myBundle resourcePath] stringByAppendingString:@"/growlnotify-1.2"];
	}
	else {
		return [[myBundle resourcePath] stringByAppendingString:@"/growlnotify-1.3"];
	}
}

- (NSString *)growlVersion //! @todo..
{
	if (growlVersion != nil) {
		return growlVersion;
	}
	@try {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *path;
		NSBundle *prefBundle;
		NSArray *librarySearchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask | NSUserDomainMask, YES); // old style, but works
		NSEnumerator *searchPathEnumerator = [librarySearchPaths objectEnumerator];
		
		while ((path = [searchPathEnumerator nextObject])) {
			path = [[path stringByAppendingPathComponent:@"PreferencePanes"] stringByAppendingPathComponent:@"Growl.prefPane"];			
			if ([fileManager fileExistsAtPath:path]) {
				prefBundle = [NSBundle bundleWithPath:path];
				if (prefBundle) {
					NSString *version = [[prefBundle infoDictionary] objectForKey:@"CFBundleVersion"];
					if ([version hasPrefix:@"1.2"]) {
						growlVersion = @"1.2";
						return growlVersion;
					}
					if ([version hasPrefix:@"1.3"] || [version hasPrefix:@"1.4"]) {
						growlVersion = @"1.3";
						return growlVersion;
					}
					return nil;
				}
			}
		}
	}
	@catch (NSException *e) {
		[self doLog: [NSString stringWithFormat:@"Exception searching growl version %@ %@ %@", [e name], [e description], [e reason]]];
	}
	@finally {
	}
	return nil;
	/*
	NSBundle *prefBundle = [NSBundle bundleWithPath: @"/Library/PreferencePanes/Growl.prefPane"]; if (prefBundle != nil) {return [[prefBundle infoDictionary] objectForKey:@"CFBundleVersion"];}
	 */
}

#pragma mark Filter

- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show useStdOut:(BOOL)usesstdout
{
	NSMutableString *resultText = [self filterTextInput:[self getEditorText] with:command options:args encoding:[[controller focusedTextView:self] encoding] useStdout:usesstdout];
	ValidationResult* myResult = [[ValidationResult alloc] init];
	
	if (resultText == nil || [resultText length] == 0) {
		[myResult setError:YES];
		[myResult setErrorMessage:[name stringByAppendingString:NSLocalizedString(@" returned nothing", @"")]];
		[myResult setAdditional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.", @"")];
	}
	else {
		[myResult setResult:resultText];
		
		if ([resultText rangeOfString:@"No warnings or errors were found"].location != NSNotFound || [resultText rangeOfString:@"No syntax errors detected"].location != NSNotFound) {
			[myResult setValid:YES];
		}
	}
	
	if ([myResult error]) {
		[messageController alertInformation:[myResult errorMessage] additional:[myResult additional] cancelButton:NO];
	}	
	else if ([myResult valid] && show) {
		[messageController showInfoMessage:[name stringByAppendingString:NSLocalizedString(@": No errors",@"")] additional:resultText];
	}
	
	return [myResult autorelease];
}

- (void)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name
{
	NSMutableString *resultText = [self filterTextInput:[self getEditorText] with:command options:args encoding:[[controller focusedTextView:self] encoding] useStdout:YES];
	
	if (resultText == nil || [resultText length] < 6) {
		[messageController alertInformation:[name stringByAppendingString:NSLocalizedString(@" returned nothing",@"")] additional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"") cancelButton:NO];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"\nFatal"]) {
		[messageController alertCriticalError:[name stringByAppendingString:NSLocalizedString(@" exception received.",@"")] additional:[NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.\n\n",@"") stringByAppendingString: resultText]];
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"!ERROR"]) {
		[messageController alertCriticalError:[name stringByAppendingFormat:@": %@",[resultText substringFromIndex:1]] additional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"")];
	}
	else {
		[self replaceEditorTextWith:resultText];
		[messageController showInfoMessage:[name stringByAppendingString:@" done"] additional:[@"File: " stringByAppendingString:[self currentFilename]]];
	}	
}

- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *dataIn;
	
	@try {
		dataIn = [textInput dataUsingEncoding: anEncoding];
		// [self doLog: [NSString stringWithFormat:@"in goes %@", textInput] ];
	
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

		[aTask setStandardInput:toPipe];
		[aTask setStandardOutput:fromPipe];
		[aTask setStandardError:errPipe];
		[aTask setArguments:cmdlineOptions];
		[aTask setLaunchPath:launchPath];
	
		[self doLog: [NSString stringWithFormat:@"Executing %@ at path %@ with %@", aTask, launchPath, cmdlineOptions] ];
		
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];

		if (anEncoding == NSUnicodeStringEncoding && [launchPath isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal]]) {
			anEncoding = NSUTF8StringEncoding; // php binary never returns utf16..
			[self doLog: @"File was UTF-16 but php binary can't handle this correctly, so falling back to UTF-8"];
		}
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData: [reading readDataToEndOfFile] encoding: anEncoding];
		
		[aTask terminate];
		// [self doLog: [NSString stringWithFormat:@"Returned %@", resultData] ];
		return resultData;
	}
	@catch (NSException *e) {	
		[self doLog: [NSString stringWithFormat:@"Exception %@ %@ %@", [e name], [e description], [e reason]]];
		[messageController alertCriticalException:e];
		return nil;
	}
	@finally {
		[aTask release];
	}
	
    return nil;
}

-(void)dealloc
{
	[preferenceController release];
	[messageController release];
	[updateController release];
	[downloadController release];
	[super dealloc];
}

@end