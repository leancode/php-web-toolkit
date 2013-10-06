//
//  PhpPlugin.h
//  PhpPlugin
//
//  Created by Mario Fischer on 23.12.08.
//  Copyright 2008/2009 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodaPluginsController.h"
#import "CwEncoding.h"
#import "CssTidyConfig.h"
#import "HtmlTidyConfig.h"
#import "CssLevel.h"
#import "CwPhpPlugin.h"
#import "PhpTidyConfig.h"
#import "JSON.h"

static unsigned int maxLengthJs = 65535;

@class CodaPlugInsController, CwPreferenceController, CwMessagingController, ValidationResult, CwUpdateController, CwDownloadController;

@interface CwPhpPlugin : NSObject <CodaPlugIn>
{
	CodaPlugInsController *controller;
	CwPreferenceController *preferenceController;
	CwMessagingController *messageController;
	CwUpdateController *updateController;
	CwDownloadController *downloadController;
	
	NSObject <CodaPlugInBundle> *myBundle;
	NSString *versionNumber;
	NSString *checkUpdateUrl;
	NSString *growlVersion;

	NSMutableData *receivedData;
	NSMutableString *currentStringValue;
	NSMutableArray *htmlTidyOptions;
}

// required coda plugin methods

//for Coda 2.0.1 and higher
- (id)initWithPlugInController:(CodaPlugInsController *)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle;
//for Coda 2.0 and lower
- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle;
- (NSString*)name;
- (BOOL)validateMenuItem:(NSMenuItem*)aMenuItem;

- (id)initWithController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle;

// actions: local validation
- (void)doValidateHtml;
- (void)doValidatePhp;
- (void)doJsLint;
- (ValidationResult*)validatePhp:(BOOL)wholeBuffer;
- (void)showPhpError:(ValidationResult*)myresult;

// actions: remote validation
- (void)doValidateRemoteCss;
- (void)doValidateRemoteCssDone:(id)sender;
- (void)doValidateRemoteHtml;
- (void)doValidateRemoteHtmlDone:(id)sender;

// actions: reformat
- (void)doTidyHtml;
- (void)doTidyCss;
- (void)doTidyPhp;
- (void)doStripPhp;
- (void)doJsTidy;
- (void)doJsMinify;
- (void)doCssMinify;

// updates
- (void)showUpdateAvailable;
- (void)checkForUpdateNow;
- (void)downloadUpdateWeb;
- (void)testUpdatePlugin;

// helpers
- (NSString*)minifyFileOnDisk:(NSString*)inputPath type:(NSString*)fileType;
- (NSString*)improveWebOutput:(NSString*)input fromDomain:(NSString*)domain;
- (void)goToHelpWebsite;
- (void)showPreferencesWindow;
- (void)showPluginResources; 
- (void)doLog:(NSString*)loggable;
- (BOOL)isCoda2;
- (void)sanityCheck;

// editor actions
- (void)displayHtmlString:(NSString*)data;
- (void)goToLine:(int)lineNumber;
- (BOOL)editorSelectionPresent;
- (BOOL)editorTextPresent;
- (NSString*)currentLineEnding;
- (NSString*)currentEncoding;
- (NSString*)getEditorText;
- (NSString*)currentFilename;
- (void)replaceEditorTextWith:(NSString*)newText;

// info getters
- (NSString*)pluginVersionNumber;
- (NSString*)pluginIconPath;
- (NSString*)phpVersion;
- (NSString*)tidyExecutable;
- (NSString*)jscInterpreter;
- (NSString*)codaPluginPath;
- (NSString*)growlVersion;

// growl
- (NSString*)growlNotify;

// filter
- (void)reformatWith:(NSString*)command arguments:(NSMutableArray*)args called:(NSString*)name;
- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show useStdOut:(BOOL)usesstdout  alwaysWholeBuffer:(BOOL)wholeBuffer;
- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray*)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout;

@end