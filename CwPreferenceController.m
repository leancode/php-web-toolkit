//
//  PreferenceController.m
//  PhpPlugin
//
//  Created by Mario Fischer on 22.09.07.
//  Copyright 2009 Mario Fischer. All rights reserved.
//

#import "CwPreferenceController.h"
#import "CwPhpPlugin.h"
#import "CssTidyConfig.h"
#import "HtmlTidyConfig.h"
#import "CssLevel.h"
#import "PhpTidyConfig.h"
#import "HtmlValidationConfig.h"

double const PrefInfoPanelAfter = 4;
float const PrefInfoPanelFadeout = 0.4;
double const PrefTimeoutNS = 20;
double const PrefMaxLogLen = 4096;
double const PrefMinSelectionLen = 5;
double const PrefDelayUpdateCheck = 29400;

NSString* const PrefHtmlValidatorUrl = @"dechipwreckHtmlValidatorUrl";
NSString* const PrefCssValidatorUrl = @"dechipwreckCssValidatorUrl";
NSString* const PrefHtmlValidatorParamFile = @"dechipwreckHtmlValidatorParamFile";
NSString* const PrefCssValidatorParamFile = @"dechipwreckCssValidatorParamFile";

NSString* const PrefPhpLocal = @"dechipwreckPHPLocal";
NSString* const PrefTidyLocal = @"dechipwreckTidyLocal";
NSString* const PrefTidyInternal = @"dechipwreckTidyInternal";
NSString* const PrefUseGrowl = @"dechipwreckUseGrowl";
NSString* const PrefResultWindow = @"dechipwreckResultWindow";
NSString* const PrefJsViaShell = @"dechipwreckJsViaShell";


NSString* const PrefDebugMode = @"dechipwreckDebugMode";
NSString* const PrefUpdateCheck = @"dechipwreckUpdateCheck";
NSString* const PrefLastUpdateCheck = @"dechipwreckLastUpdateCheck";
NSString* const PrefAutoSave = @"dechipwreckAutoSave";
NSString* const PrefPhpOnSave = @"dechipwreckPhpOnSave";
NSString* const PrefPhpBeepOnly = @"dechipwreckPhpBeepOnly";
NSString* const PrefUseSelection = @"dechipwreckUseSelection";
NSString* const PrefPhpExtensions = @"dechipwreckPhpExtensions";
NSString* const PrefMinExtensions = @"dechipwreckMinExtensions";

NSString* const PrefCssTidyConfig = @"dechipwreckCssTidyConfig";
NSString* const PrefHtmlTidyConfig = @"dechipwreckHtmlTidyConfig";
NSString* const PrefHtmlTidyCustomConfig = @"dechipwreckHtmlTidyCustomConfig";

NSString* const PrefMsgShown = @"dechipwreckPrefMsgShown";
NSString* const PrefLastVersionRun = @"dechipwreckPrefLastVersionRun";

NSString* const PrefCssLevel = @"dechipwreckPrefCssLevel";
NSString* const PrefCssTidyRemoveLast = @"dechipwreckPrefCssTidyRemoveLast";
NSString* const PrefCssMinifyOnPublish = @"dechipwreckPrefCssMinifyOnPublish";
NSString* const PrefJsMinifyOnPublish = @"dechipwreckPrefJsMinifyOnPublish";

NSString* const PrefPhpTidyBraces = @"dechipwreckPrefPhpTidyBraces";
NSString* const PrefPhpTidyBlankLines = @"dechipwreckPrefPhpTidyBlankLines";
NSString* const PrefPhpTidyComma = @"dechipwreckPrefPhpTidyComma";
NSString* const PrefPhpTidyWhitespace = @"dechipwreckPrefPhpTidyWhitespace";
NSString* const PrefPhpTidyFixBrackets = @"dechipwreckPrefPhpTidyFixBrackets";
NSString* const PrefPhpTidyReplacePhpTags = @"dechipwreckPrefPhpTidyReplacePhpTags";
NSString* const PrefPhpTidyReplaceShellComments = @"dechipwreckPrefPhpTidyReplaceShellComments";

NSString* const PrefJSHintAsi = @"dechipwreckPrefJSHintAsi";
NSString* const PrefJSHintCurly = @"dechipwreckPrefJSHintCurly";
NSString* const PrefJSHintEqeqeq = @"dechipwreckPrefJSHintEqeqeq";
NSString* const PrefJSHintEvil = @"dechipwreckPrefJSHintEvil";
NSString* const PrefJSHintForin = @"dechipwreckPrefJSHintForin";
NSString* const PrefJSHintImmed = @"dechipwreckPrefJSHintImmed";
NSString* const PrefJSHintLoopfunc = @"dechipwreckPrefJSHintLoopfunc";
NSString* const PrefJSHintSafe = @"dechipwreckPrefJSHintSafe"; // unused
NSString* const PrefJSHintStrict = @"dechipwreckPrefJSHintStrict";
NSString* const PrefJSHintSub = @"dechipwreckPrefJSHintSub";

NSString* const PrefJSHintBitwise = @"dechipwreckPrefJSHintBitwise";
NSString* const PrefJSHintNewcap = @"dechipwreckPrefJSHintNewcap";
NSString* const PrefJSHintNoempty = @"dechipwreckPrefJSHintNoempty";
NSString* const PrefJSHintNomen = @"dechipwreckPrefJSHintNomen";
NSString* const PrefJSHintOnevar = @"dechipwreckPrefJSHintOnevar";
NSString* const PrefJSHintPlusplus = @"dechipwreckPrefJSHintPlusplus";
NSString* const PrefJSHintRegexp = @"dechipwreckPrefJSHintRegexp";
NSString* const PrefJSHintUndef = @"dechipwreckPrefJSHintUndef";
NSString* const PrefJSHintWhite = @"dechipwreckPrefJSHintWhite";
NSString* const PrefJSHintSmartTabs = @"dechipwreckPrefJSHintSmartTabs";

NSString* const PrefJSHintEqnull = @"dechipwreckPrefJSHintEqnull";
NSString* const PrefJSHintNoarg = @"dechipwreckPrefJSHintNoarg";
NSString* const PrefJSHintNonew = @"dechipwreckPrefJSHintNonew";
NSString* const PrefJSHintBoss = @"dechipwreckPrefJSHintBoss";
NSString* const PrefJSHintShadow = @"dechipwreckPrefJSHintShadow";
NSString* const PrefJSHintLatedef = @"dechipwreckPrefJSHintLatedef";
NSString* const PrefJSHintGlobalstrict = @"dechipwreckPrefJSHintGlobalstrict";

NSString* const PrefJSTidyPreserveNewlines = @"dechipwreckPrefJSTidyPreserveNewlines";
NSString* const PrefJSTidySpaceAfterAnonFunction = @"dechipwreckPrefJSTidySpaceAfterAnonFunction";
NSString* const PrefJSTidyBracesOnOwnLine = @"dechipwreckPrefJSTidyBracesOnOwnLine";
NSString* const PrefJSTidyIndentSize = @"dechipwreckPrefJSTidyIndentSize";

NSString* const UrlHomepage =  @"http://www.chipwreck.de/blog/software/coda-php/?utm_source=prefs&utm_medium=plugin&utm_campaign=homelink";
NSString* const UrlDonationpage = @"http://www.chipwreck.de/blog/about/donate/?utm_source=prefs&utm_medium=plugin&utm_campaign=donationlink#donate";
NSString* const UrlTwitter = @"http://www.chipwreck.de/blog/about/donate/?utm_source=prefs&utm_medium=plugin&utm_campaign=twitterlink#twitter";
NSString* const UrlFacebook = @"http://www.chipwreck.de/blog/about/donate/?utm_source=prefs&utm_medium=plugin&utm_campaign=facebooklink#facebook";
NSString* const UrlGoogle = @"http://www.chipwreck.de/blog/about/donate/?utm_source=prefs&utm_medium=plugin&utm_campaign=googlelink#gplus";
NSString* const UrlHelp = @"http://www.chipwreck.de/blog/software/coda-php/help/?utm_source=plugin&utm_medium=plugin&utm_campaign=helplink#quick";
NSString* const UrlProCSSor = @"http://procssorapp.com/?q=coda";
NSString* const UrlTidyHelp = @"http://tidy.sourceforge.net/docs/quickref.html";
NSString* const UrlJsHintHelp = @"http://www.jshint.com/options/";
NSString* const UrlVersionCheck = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/versioncheck2.php?sw=codaphp&rnd=483&utm_source=updatecheck&utm_medium=plugin&utm_campaign=checkupdate&version=";
NSString* const UrlDownload = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=";
NSString* const UrlDownloadDirect = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&direct=1&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=";
NSString* const UrlDownloadTest = @"http://www.chipwreck.de/downloads/php-codaplugin-3.1beta.zip";
	
@implementation CwPreferenceController

# pragma mark -
# pragma mark Init and windowspecific

- (id)init 
{ 
	self = [super initWithWindowNibName:@"Preferences"];
	//	[[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately: NO];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:[self getDefaults]];
	[self setDefaults];
	return self; 
}

- (void)setMyPlugin:(CwPhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (void)setBundlePath: (NSString *)thePath
{
	bundlePath = [[NSString alloc] initWithString:thePath];
}

- (void)windowDidLoad
{
	[cssConfigBtn selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: PrefCssTidyConfig]];
	[htmlConfigBtn selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: PrefHtmlTidyConfig]];
	[cssLevelBtn selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: PrefCssLevel]];
	[phpTidyBracesBtn selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: PrefPhpTidyBraces]];
	
	[htmlValidator setSelectedSegment:
	 [[HtmlValidationConfig configForUrl:[[NSUserDefaults standardUserDefaults] stringForKey:PrefHtmlValidatorUrl] ] intvalue]
	 ];
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlTidyCustomConfig] != nil) {
		[customTidyConfig setString:[[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlTidyCustomConfig]];
	}
	else {
		[self loadHtmlTidyCustomConfig];		
	}
	[self htmlConfigModified:self];
	[self phpValidateOnSaveModified:self];
	
	[versionNumberField setStringValue: [myPlugin pluginVersionNumber]];
	[phpversionNumberField setStringValue: [myPlugin phpVersion]];
}

- (NSMutableDictionary *)getDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:@"http://jigsaw.w3.org/css-validator/validator" forKey: PrefCssValidatorUrl];
	[defaultValues setObject:@"http://html5.validator.nu" forKey: PrefHtmlValidatorUrl];
	[defaultValues setObject:@"file" forKey: PrefCssValidatorParamFile];
	[defaultValues setObject:@"file" forKey: PrefHtmlValidatorParamFile];
	[defaultValues setObject:@"/usr/bin/php" forKey: PrefPhpLocal];
	[defaultValues setObject:@"php,phtml" forKey: PrefPhpExtensions];
	[defaultValues setValue:[NSNumber numberWithInt:1] forKey: PrefJsViaShell];
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey: PrefUseGrowl];
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey: PrefDebugMode];
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey: PrefUseSelection];
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey: PrefAutoSave];
	[defaultValues setValue:[NSNumber numberWithInt:1] forKey: PrefResultWindow];
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey: PrefPhpBeepOnly];
	[defaultValues setValue:[NSNumber numberWithInt:1] forKey: PrefTidyInternal];
	[defaultValues setValue:[NSNumber numberWithInt:1] forKey: PrefUpdateCheck];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey: PrefCssTidyConfig];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey: PrefHtmlTidyConfig];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey: PrefCssLevel];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey: PrefPhpTidyReplacePhpTags];
	
	return defaultValues;
}

- (void)setDefaults
{
	[[NSUserDefaults standardUserDefaults] registerDefaults: [self getDefaults]];
}

- (IBAction)resetPressed: (id)sender
{
	[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:sender];
	[self htmlConfigModified:self];
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL canClose = true;
	
	if (! [self fileExists:[fieldPhpLocal stringValue]] ) {
		canClose = false;
		[labelPhpLocal setTextColor:[NSColor redColor]];
	}
	else {		
		[labelPhpLocal setTextColor:[NSColor controlTextColor]];
	}
	
	if (canClose) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[cssConfigBtn indexOfSelectedItem]] forKey: PrefCssTidyConfig];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[htmlConfigBtn indexOfSelectedItem]] forKey: PrefHtmlTidyConfig];
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:[customTidyConfig string]] forKey: PrefHtmlTidyCustomConfig];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[cssLevelBtn indexOfSelectedItem]] forKey: PrefCssLevel];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[phpTidyBracesBtn indexOfSelectedItem]] forKey: PrefPhpTidyBraces];
		// [[NSUserDefaultsController sharedUserDefaultsController] save:sender];
		
		[labelPhpLocal setTextColor:[NSColor controlTextColor]];
		
		[self saveHtmlTidyCustomConfig:[customTidyConfig string]];
		
		return YES;	
	}
	else {
		NSBeep();
		[tabView selectTabViewItemAtIndex:([tabView numberOfTabViewItems] - 1)];
		return NO;
	}	
}

# pragma mark -
# pragma mark Arrays

- (NSArray *)cssTidyConfigs
{
    return [CssTidyConfig configArray];
}
- (NSArray *)cssLevels
{
    return [CssLevel configArray];
}
- (NSArray *)phpTidyBraces
{
	return [PhpTidyConfig configArray];
}
- (NSArray *)htmlTidyConfigs
{
    return [HtmlTidyConfig configArray];
}

# pragma mark -
# pragma mark Actions

- (IBAction)htmlConfigModified: (id)sender
{
	if ([htmlConfigBtn indexOfSelectedItem] == 5) {
		[self enableTextView:customTidyConfig As:YES];
	}
	else {
		[self enableTextView:customTidyConfig As:NO];
	}
}

- (IBAction)phpValidateOnSaveModified: (id)sender
{
	[phpExtensions setEnabled:([phpValidateSaveBtn state] == YES)];
	[phpExtensions setStringValue:[[phpExtensions stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

-(void)enableTextView:(NSTextView *)textView As:(BOOL)enableIt
{
	[textView setSelectable: enableIt];
	[textView setEditable: enableIt];
    if (enableIt) {
		[textView setTextColor: [NSColor controlTextColor]];
	}		
	else {
		[textView setTextColor: [NSColor disabledControlTextColor]];
	}
}

# pragma mark -
# pragma mark Actions

- (IBAction)goToTidyDocumentationWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlTidyHelp]];
}

- (IBAction)goToJsHintDocumentationWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlJsHintHelp]];	
}

- (IBAction)goToHelpWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlHelp]];
}

- (IBAction)goToProcssor:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlProCSSor]];
}

- (IBAction)goToDonationPage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlDonationpage]];
}

- (IBAction)goToPluginHomepage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlHomepage]];
}

- (IBAction)goToFacebook:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlFacebook]];
}

- (IBAction)goToTwitter:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlTwitter]];	
}

- (IBAction)goToGoogle:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString: UrlGoogle]];
}

- (IBAction)selectHTMLValidator:(id)sender
{
	HtmlValidationConfig* selConfig = [HtmlValidationConfig configForIndex:[htmlValidator selectedSegment]];
	
	[htmlValidatorUrl setStringValue:[selConfig validationUrl]];
	[htmlValidatorFieldname setStringValue:[selConfig validationFieldname]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[selConfig validationUrl] forKey: PrefHtmlValidatorUrl];
	[[NSUserDefaults standardUserDefaults] setObject:[selConfig validationFieldname] forKey: PrefHtmlValidatorParamFile];
}

# pragma mark -
# pragma mark Helpers

- (void)loadHtmlTidyCustomConfig
{
	if (bundlePath != nil) {
		NSString *path = [bundlePath stringByAppendingString:@"/tidy_config_format_default.txt"];
		NSError *error;

		if ( [self fileExists:path ] ) {
			NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	
			if (fileContents == nil) {
				[myPlugin doLog:[NSString stringWithFormat:@"Error reading tidy configuration from %@\n%@", path, [error localizedFailureReason]]];
			}
			else {
				[customTidyConfig setString:fileContents];
			}
		}
	}
}

- (void)saveHtmlTidyCustomConfig:(NSString *)contents
{
	if (bundlePath != nil) {
		
		NSString *path = [bundlePath stringByAppendingString:@"/tidy_config_format_custom.txt"];
		NSError *error;
		
		BOOL isok = [contents writeToFile:path atomically:YES encoding: NSUTF8StringEncoding error:&error];
		if (!isok) {
			[myPlugin doLog:[NSString stringWithFormat:@"Error writing tidy configuration from %@\n%@", path, [error localizedFailureReason]]];
		}
	}
}

- (BOOL)fileExists: (NSString *)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return ([fileManager fileExistsAtPath:filePath]);	
}

- (void)dealloc
{
	[bundlePath dealloc];
	[super dealloc];
}

@end