//
//  PhpPlugin.h
//  PhpPlugin
//
//  Created by Mario Fischer on 23.12.08.
//  Copyright 2008/2009 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodaPluginsController.h"
#import "Encoding.h"
#import "CssTidyConfig.h"
#import "HtmlTidyConfig.h"
#import "CssLevel.h"
#import "CssProcssor.h"
#import "PhpPlugin.h"
#import "PhpTidyConfig.h"
#import "JSON.h"

@class CodaPlugInsController, PreferenceController, MessagingController, ValidationResult, UpdateController;

@interface PhpPlugin : NSObject <CodaPlugIn>
{
	CodaPlugInsController *controller;
	PreferenceController *preferenceController;
	MessagingController *messageController;
	UpdateController *updateController;
	
	NSBundle *myBundle;
	NSString *versionNumber;
	NSString *checkUpdateUrl;

	int timeoutValue;
	
	NSMutableData *receivedData;
	NSMutableString *currentStringValue;
	NSMutableArray *htmlTidyOptions;
}

// required coda plugin methods
- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle;
- (NSString*)name;
- (BOOL)validateMenuItem:(NSMenuItem*)aMenuItem;

// actions
- (void)validatePhp;
- (void)doStripPhp;
- (void)doValidateRemoteCss;
- (void)doValidateRemoteHtml;
- (void)doValidateHtml;
- (void)doTidyHtml;
- (void)doTidyCss;
- (void)doProcssorRemote;
- (void)doTidyPhp;
- (void)doJsTidy;
- (void)doJsLint;
- (void)doJsMinify;

// updates
- (void)showUpdateAvailable;
- (void)checkForUpdateNow;
- (IBAction)downloadUpdate:(id)sender;

// helpers
- (NSMutableString*)escapeEntities:(NSMutableString *)myString;
- (NSString*)improveWebOutput:(NSString*)input fromDomain:(NSString*)domain;
- (void)goToHelpWebsite;
- (void)showPreferencesWindow;
- (void)doLog:(NSString*)loggable;

// editor actions
- (void)displayHtmlString:(NSString*)data;
- (void)goToLine:(int)lineNumber;
- (BOOL)editorSelectionPresent;
- (BOOL)editorTextPresent;
- (BOOL)editorPathPresent;
- (NSString*)currentLineEnding:(CodaTextView *)myview;
- (NSString*)currentEncoding:(CodaTextView *)myview;
- (NSString*)getEditorText;
- (void)replaceEditorTextWith:(NSString*)newText;

// info getters
- (NSString*)pluginVersionNumber;
- (NSString *)pluginIconPath;
- (NSString*)phpVersion;
- (NSString*)curlVersion;
- (NSString*)tidyExecutable;
- (NSString*)tidyVersion;

// growl

- (NSString *)growlNotify;
- (BOOL)useGrowl;

// filter
- (void)reformatWith:(NSString*)command arguments:(NSMutableArray*)args called:(NSString*)name;
- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show;
- (NSMutableString *)executeFilter:(NSString*)command arguments:(NSMutableArray*)args usestdout:(BOOL)yesorno;
- (NSString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray*)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout;

@end