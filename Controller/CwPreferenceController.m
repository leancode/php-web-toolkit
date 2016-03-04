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
NSString* const PrefHtmlTidy5 = @"decipwreckHtmlTidy5";
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
NSString* const PrefPhpTidyBlankLinesNums = @"dechipwreckPrefPhpTidyBlankLinesNums";
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
NSString* const PrefJSHintNomen = @"dechipwreckPrefJSHintNomen"; // legacy, unused
NSString* const PrefJSHintOnevar = @"dechipwreckPrefJSHintOnevar";
NSString* const PrefJSHintPlusplus = @"dechipwreckPrefJSHintPlusplus";
NSString* const PrefJSHintRegexp = @"dechipwreckPrefJSHintRegexp";
NSString* const PrefJSHintUndef = @"dechipwreckPrefJSHintUndef";// legacy, unused
NSString* const PrefJSHintWhite = @"dechipwreckPrefJSHintWhite"; // legacy, unused
NSString* const PrefJSHintSmartTabs = @"dechipwreckPrefJSHintSmartTabs";
NSString* const PrefJSHintLaxComma = @"dechipwreckPrefJSHintLaxComma";

NSString* const PrefJSHintEqnull = @"dechipwreckPrefJSHintEqnull";
NSString* const PrefJSHintNoarg = @"dechipwreckPrefJSHintNoarg";
NSString* const PrefJSHintNonew = @"dechipwreckPrefJSHintNonew";
NSString* const PrefJSHintBoss = @"dechipwreckPrefJSHintBoss";
NSString* const PrefJSHintShadow = @"dechipwreckPrefJSHintShadow";
NSString* const PrefJSHintLatedef = @"dechipwreckPrefJSHintLatedef";
NSString* const PrefJSHintGlobalstrict = @"dechipwreckPrefJSHintGlobalstrict";

NSString* const PrefJSHintValidateOnSave = @"dechipwreckPrefJSHintValidateOnSave";
NSString* const PrefJSHintOptions = @"dechipwreckPrefJSHintOptions";

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
NSString* const UrlJsHintHelp = @"http://www.jshint.com/docs/options/";
NSString* const UrlVersionCheck = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/versioncheck2.php?sw=codaphp&rnd=483&utm_source=updatecheck&utm_medium=plugin&utm_campaign=checkupdate&version=";
NSString* const UrlDownload = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=";
NSString* const UrlDownloadDirect = @"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&direct=1&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=";
NSString* const UrlDownloadTest = @"http://www.chipwreck.de/downloads/php-codaplugin-3.1beta.zip";
	
@implementation CwPreferenceController

# pragma mark -
# pragma mark Init and windowspecific

- (instancetype)init 
{ 
	self = [super initWithWindowNibName:@"Preferences"];
	//	[[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately: NO];
	[NSUserDefaultsController sharedUserDefaultsController].initialValues = [self getDefaults];
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
	[phpTidyBlankLinesBtn selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey: PrefPhpTidyBlankLinesNums]];
	
	htmlValidator.selectedSegment = [HtmlValidationConfig configForUrl:[[NSUserDefaults standardUserDefaults] stringForKey:PrefHtmlValidatorUrl] ].intvalue
	 ;
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlTidyCustomConfig] != nil) {
		customTidyConfig.string = [[NSUserDefaults standardUserDefaults] stringForKey: PrefHtmlTidyCustomConfig];
	}
	else {
		[self loadHtmlTidyCustomConfig];		
	}
	[self htmlConfigModified:self];
	[self phpValidateOnSaveModified:self];
	
	versionNumberField.stringValue = [myPlugin pluginVersionNumber];
	phpversionNumberField.stringValue = [myPlugin phpVersion];
}

- (NSMutableDictionary *)getDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	defaultValues[PrefCssValidatorUrl] = @"http://jigsaw.w3.org/css-validator/validator";
	defaultValues[PrefHtmlValidatorUrl] = @"http://html5.validator.nu";
	defaultValues[PrefCssValidatorParamFile] = @"file";
	defaultValues[PrefHtmlValidatorParamFile] = @"file";
	defaultValues[PrefPhpLocal] = @"/usr/bin/php";
	defaultValues[PrefPhpExtensions] = @"php,phtml";
	[defaultValues setValue:@1 forKey: PrefJsViaShell];
	[defaultValues setValue:@0 forKey: PrefUseGrowl];
	[defaultValues setValue:@0 forKey: PrefDebugMode];
	[defaultValues setValue:@0 forKey: PrefUseSelection];
	[defaultValues setValue:@0 forKey: PrefAutoSave];
	[defaultValues setValue:@1 forKey: PrefResultWindow];
	[defaultValues setValue:@0 forKey: PrefPhpBeepOnly];
	[defaultValues setValue:@1 forKey: PrefTidyInternal];
	[defaultValues setValue:@1 forKey: PrefUpdateCheck];
	defaultValues[PrefCssTidyConfig] = @1;
	defaultValues[PrefHtmlTidyConfig] = @1;
	defaultValues[PrefCssLevel] = @1;
	defaultValues[PrefPhpTidyReplacePhpTags] = @1;
	
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
	
	if (! [self fileExists:fieldPhpLocal.stringValue] ) {
		canClose = false;
		labelPhpLocal.textColor = [NSColor redColor];
	}
	else {		
		labelPhpLocal.textColor = [NSColor controlTextColor];
	}
	
	if (canClose) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:cssConfigBtn.indexOfSelectedItem] forKey: PrefCssTidyConfig];
		[[NSUserDefaults standardUserDefaults] setObject:@(htmlConfigBtn.indexOfSelectedItem) forKey: PrefHtmlTidyConfig];
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:customTidyConfig.string] forKey: PrefHtmlTidyCustomConfig];
		[[NSUserDefaults standardUserDefaults] setObject:@(cssLevelBtn.indexOfSelectedItem) forKey: PrefCssLevel];
		[[NSUserDefaults standardUserDefaults] setObject:@(phpTidyBracesBtn.indexOfSelectedItem) forKey: PrefPhpTidyBraces];
		[[NSUserDefaults standardUserDefaults] setObject:@(phpTidyBlankLinesBtn.indexOfSelectedItem) forKey: PrefPhpTidyBlankLinesNums];
		// [[NSUserDefaultsController sharedUserDefaultsController] save:sender];
		
		labelPhpLocal.textColor = [NSColor controlTextColor];
		
		[self saveHtmlTidyCustomConfig:customTidyConfig.string];
		
		return YES;	
	}
	else {
		NSBeep();
		[tabView selectTabViewItemAtIndex:(tabView.numberOfTabViewItems - 1)];
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
- (NSArray *)phpTidyBlankLines
{
	return [PhpTidyBLNConfig configArray];
}
- (NSArray *)htmlTidyConfigs
{
    return [HtmlTidyConfig configArray];
}

# pragma mark -
# pragma mark Actions

- (IBAction)htmlConfigModified: (id)sender
{
	if (htmlConfigBtn.indexOfSelectedItem == 5) {
		[self enableTextView:customTidyConfig As:YES];
	}
	else {
		[self enableTextView:customTidyConfig As:NO];
	}
}

- (IBAction)phpValidateOnSaveModified: (id)sender
{
	phpExtensions.enabled = (phpValidateSaveBtn.state == YES);
	phpExtensions.stringValue = [phpExtensions.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)enableTextView:(NSTextView *)textView As:(BOOL)enableIt
{
	textView.selectable = enableIt;
	textView.editable = enableIt;
    if (enableIt) {
		textView.textColor = [NSColor controlTextColor];
	}		
	else {
		textView.textColor = [NSColor disabledControlTextColor];
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
	HtmlValidationConfig* selConfig = [HtmlValidationConfig configForIndex:htmlValidator.selectedSegment];
	
	htmlValidatorUrl.stringValue = selConfig.validationUrl;
	htmlValidatorFieldname.stringValue = selConfig.validationFieldname;
	
	[[NSUserDefaults standardUserDefaults] setObject:selConfig.validationUrl forKey: PrefHtmlValidatorUrl];
	[[NSUserDefaults standardUserDefaults] setObject:selConfig.validationFieldname forKey: PrefHtmlValidatorParamFile];
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
				[myPlugin doLog:[NSString stringWithFormat:@"Error reading tidy configuration from %@\n%@", path, error.localizedFailureReason]];
			}
			else {
				customTidyConfig.string = fileContents;
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
			[myPlugin doLog:[NSString stringWithFormat:@"Error writing tidy configuration from %@\n%@", path, error.localizedFailureReason]];
		}
	}
}

- (BOOL)fileExists: (NSString *)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return ([fileManager fileExistsAtPath:filePath]);	
}


@end