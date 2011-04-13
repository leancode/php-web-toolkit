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

@class CodaPlugInsController, PreferenceController, MessagingController, ValidationResult, UpdateController, DownloadController;

@interface PhpPlugin : NSObject <CodaPlugIn>
{
	CodaPlugInsController *controller;
	PreferenceController *preferenceController;
	MessagingController *messageController;
	UpdateController *updateController;
	DownloadController *downloadController;
	
	NSBundle *myBundle;
	NSString *versionNumber;
	NSString *checkUpdateUrl;

	NSMutableData *receivedData;
	NSMutableString *currentStringValue;
	NSMutableArray *htmlTidyOptions;
}

// required coda plugin methods
- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle;
- (NSString*)name;
- (BOOL)validateMenuItem:(NSMenuItem*)aMenuItem;

// actions: local validation
- (void)doValidateHtml;
- (void)doValidatePhp;
- (void)doJsLint;

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
- (void)doProcssorRemote;
- (void)doProcssorRemoteDone:(id)sender;
- (void)doJsTidy;
- (void)doJsMinify;

// updates
- (void)showUpdateAvailable;
- (void)checkForUpdateNow;

// helpers
- (NSString*)improveWebOutput:(NSString*)input fromDomain:(NSString*)domain;
- (void)goToHelpWebsite;
- (void)showPreferencesWindow;
- (void)doLog:(NSString*)loggable;

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
- (NSString *)pluginIconPath;
- (NSString*)phpVersion;
- (NSString*)tidyExecutable;
- (NSString*)tidyVersion;
- (NSString*)jscInterpreter;

// growl
- (NSString *)growlNotify;

// filter
- (void)reformatWith:(NSString*)command arguments:(NSMutableArray*)args called:(NSString*)name;
- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show useStdOut:(BOOL)usesstdout;
- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray*)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout;

@end