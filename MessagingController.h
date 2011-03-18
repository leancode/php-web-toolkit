//
//  MessagingController.h
//  PhpPlugin
//
//  Created by Mario Fischer on 08.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class PhpPlugin;

@interface MessagingController : NSWindowController // <GrowlApplicationBridgeDelegate>
{
	PhpPlugin *myPlugin;
	NSString *bundlePath;
	
	IBOutlet NSWindow *sheetMessage;
	IBOutlet NSButton *messageCancelButton;
	IBOutlet NSTextField *messageText;
	
	IBOutlet NSWindow *sheetPhpError;
	IBOutlet NSTextField *phpErrorText;
	
	IBOutlet NSPanel *infoPanel;
	IBOutlet NSTextField *infoText;
	IBOutlet NSTextField *infoTextAdditional;
	
	IBOutlet NSPanel *resultPanel;
	IBOutlet WebView *resultView;
	IBOutlet NSTextField *resultLabel;

	NSTimer *panelTimer;
	int durationInfoPanel;
	int lineOfErrorSaved;
}

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance;
- (void)setBundlePath: (NSString *)thePath;

- (int)showAlert:(NSAlertStyle)alertStyle message:(NSString*)msg additional:(NSString*)addMsg secondButton:(NSString*)secondButton;
- (int)alertInformation:(NSString*)errMsg additional:(NSString*)addMsg cancelButton:(BOOL)yesorno;
- (void)alertCriticalError:(NSString*)errMsg additional:(NSString*)addMsg;
- (void)alertCriticalException:(NSException*)e;
- (void)showInfoMessage:(NSString*)msg additional:(NSString*)additionalText;
- (void)showInfoMessage:(NSString*)msg additional:(NSString*)additionalText sticky:(BOOL)isSticky;
- (void)hideInfoMessage: (BOOL)fadeout;

- (void)showResult:(NSString *)data forUrl:(NSString *)baseurl withTitle:(NSString *)title;
- (IBAction)closeResult:(id)sender;
- (IBAction)clearResult:(id)sender;
+ (NSString*)getCssForJsLint;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;

- (void)openSheetPhpError:(NSString*)error atLine:(int)lineOfError forWindow:(NSWindow*)window;
- (IBAction)goToPhpErrorLine:(id)sender;
- (IBAction)dismissPhpError:(id)sender;
- (void)sheetDidEndPhpError:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)growlNotify:(NSString *)title description:(NSString *)desc sticky:(BOOL)isSticky;

@end
