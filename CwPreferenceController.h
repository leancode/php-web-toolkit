//
//  PreferenceController.h
//  PhpPlugin
//
//  Created by Mario Fischer on 22.09.07.
//  Copyright 2009 Mario Fischer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CwPhpPlugin;

extern double const PrefInfoPanelAfter;
extern float const PrefInfoPanelFadeout;
extern double const PrefTimeoutNS;
extern double const PrefMaxLogLen;
extern double const PrefMinSelectionLen;
extern double const PrefDelayUpdateCheck;

extern NSString* const PrefHtmlValidatorUrl;
extern NSString* const PrefCssValidatorUrl;
extern NSString* const PrefHtmlValidatorParamFile;
extern NSString* const PrefCssValidatorParamFile;

extern NSString* const PrefPhpLocal;
extern NSString* const PrefTidyLocal;
extern NSString* const PrefTidyInternal;
extern NSString* const PrefUseGrowl;
extern NSString* const PrefResultWindow;
extern NSString* const PrefJsViaShell;

extern NSString* const PrefDebugMode;
extern NSString* const PrefUpdateCheck;
extern NSString* const PrefLastUpdateCheck;
extern NSString* const PrefAutoSave;
extern NSString* const PrefPhpOnSave;
extern NSString* const PrefPhpBeepOnly;
extern NSString* const PrefUseSelection;
extern NSString* const PrefPhpExtensions;
extern NSString* const PrefMinExtensions;

extern NSString* const PrefCssTidyConfig;
extern NSString* const PrefHtmlTidyConfig;
extern NSString* const PrefHtmlTidyCustomConfig;

extern NSString* const PrefMsgShown;
extern NSString* const PrefLastVersionRun;
extern NSString* const PrefCssLevel;
extern NSString* const PrefCssTidyRemoveLast;
extern NSString* const PrefCssMinifyOnPublish;
extern NSString* const PrefJsMinifyOnPublish;

extern NSString* const PrefPhpTidyBraces;
extern NSString* const PrefPhpTidyBlankLines;
extern NSString* const PrefPhpTidyComma;
extern NSString* const PrefPhpTidyWhitespace;
extern NSString* const PrefPhpTidyFixBrackets;
extern NSString* const PrefPhpTidyReplacePhpTags;
extern NSString* const PrefPhpTidyReplaceShellComments;

extern NSString* const PrefJSHintAsi;
extern NSString* const PrefJSHintBitwise;
extern NSString* const PrefJSHintCurly;
extern NSString* const PrefJSHintEqeqeq;
extern NSString* const PrefJSHintEvil;
extern NSString* const PrefJSHintForin;
extern NSString* const PrefJSHintImmed;
extern NSString* const PrefJSHintLoopfunc;
extern NSString* const PrefJSHintNewcap;
extern NSString* const PrefJSHintNoempty; 
extern NSString* const PrefJSHintNomen;
extern NSString* const PrefJSHintOnevar;
extern NSString* const PrefJSHintPlusplus;
extern NSString* const PrefJSHintRegexp;
extern NSString* const PrefJSHintSafe; // unused
extern NSString* const PrefJSHintStrict;
extern NSString* const PrefJSHintSub;
extern NSString* const PrefJSHintUndef;
extern NSString* const PrefJSHintWhite;
extern NSString* const PrefJSHintSmartTabs;
extern NSString* const PrefJSHintLaxComma;

extern NSString* const PrefJSHintEqnull;
extern NSString* const PrefJSHintNoarg;
extern NSString* const PrefJSHintNonew; 
extern NSString* const PrefJSHintBoss;
extern NSString* const PrefJSHintShadow;
extern NSString* const PrefJSHintLatedef;
extern NSString* const PrefJSHintGlobalstrict;

extern NSString* const PrefJSHintValidateOnSave;

extern NSString* const PrefJSTidyPreserveNewlines;
extern NSString* const PrefJSTidySpaceAfterAnonFunction;
extern NSString* const PrefJSTidyBracesOnOwnLine;
extern NSString* const PrefJSTidyIndentSize;

extern NSString* const UrlHomepage;
extern NSString* const UrlDonationpage;
extern NSString* const UrlTwitter;
extern NSString* const UrlFacebook;
extern NSString* const UrlGoogle;
extern NSString* const UrlHelp;
extern NSString* const UrlProCSSor;
extern NSString* const UrlTidyHelp;
extern NSString* const UrlJsHintHelp;
extern NSString* const UrlVersionCheck;
extern NSString* const UrlDownload;
extern NSString* const UrlDownloadDirect;
extern NSString* const UrlDownloadTest;

@interface CwPreferenceController : NSWindowController
{	
	CwPhpPlugin *myPlugin;
	NSString *bundlePath;

	IBOutlet NSPanel *prefPanel;
	IBOutlet NSTabView *tabView;
	
	IBOutlet NSButton *useResultWindowBtn;
	
	IBOutlet NSButton *useGrowlBtn;
	IBOutlet NSButton *phpValidateSaveBtn;
	
	IBOutlet NSSegmentedCell *htmlValidator;
	
	IBOutlet NSPopUpButton *cssConfigBtn;
	IBOutlet NSPopUpButton *htmlConfigBtn;
	
	IBOutlet NSPopUpButton *cssLevelBtn;
	
	IBOutlet NSPopUpButton *phpTidyBracesBtn;
	
	IBOutlet NSTextField *labelPhpLocal;
	IBOutlet NSTextField *fieldPhpLocal;
	
	IBOutlet NSTextField *phpExtensions;
	
	IBOutlet NSTextField *htmlValidatorUrl;
	IBOutlet NSTextField *htmlValidatorFieldname;
	
	IBOutlet NSTextField *versionNumberField;
	IBOutlet NSTextField *phpversionNumberField;
	
	IBOutlet NSTextView *customTidyConfig;

}
- (void)setMyPlugin:(CwPhpPlugin*)myPluginInstance;
- (void)setBundlePath: (NSString*)thePath;
- (void)windowDidLoad;
- (NSMutableDictionary *)getDefaults;
- (void)setDefaults;
- (IBAction)resetPressed: (id)sender;
- (BOOL)windowShouldClose:(id)sender;

- (NSArray *)cssTidyConfigs;
- (NSArray *)cssLevels;
- (NSArray *)phpTidyBraces;
- (NSArray *)htmlTidyConfigs;

- (IBAction)htmlConfigModified: (id)sender;
- (IBAction)phpValidateOnSaveModified: (id)sender;
- (void)enableTextView:(NSTextView*)textView As:(BOOL)enableIt;
- (IBAction)selectHTMLValidator:(id)sender;

- (IBAction)goToHelpWebsite:(id)sender;
- (IBAction)goToTidyDocumentationWebsite:(id)sender;
- (IBAction)goToJsHintDocumentationWebsite:(id)sender;
- (IBAction)goToProcssor:(id)sender;
- (IBAction)goToDonationPage:(id)sender;
- (IBAction)goToFacebook:(id)sender;
- (IBAction)goToTwitter:(id)sender;
- (IBAction)goToGoogle:(id)sender;
- (IBAction)goToPluginHomepage:(id)sender;

- (BOOL)fileExists: (NSString*)filePath;
- (void)loadHtmlTidyCustomConfig;
- (void)saveHtmlTidyCustomConfig:(NSString*)contents;

@end