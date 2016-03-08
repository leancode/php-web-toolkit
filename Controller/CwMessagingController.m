//
//  CwMessagingController.m
//  PhpPlugin
//
//  Created by Mario Fischer on 08.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "CwMessagingController.h"
#import "CwPreferenceController.h"
#import "CwPhpPlugin.h"

@implementation CwMessagingController

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		@try {
			NSString *nibName1 = @"InfoPanel";
			NSString *nibName2 = @"SheetPHPError";
			NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
			if([myBundle respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]){
				NSArray * t = nil;
				NSArray * t2 = nil;
				if(![myBundle loadNibNamed:nibName1 owner:self topLevelObjects:&t]){
					[self alertCriticalError:[NSString stringWithFormat:@"Could not load nib named: %@", nibName1] additional:nil];
					return nil;
				}
				if(![myBundle loadNibNamed:nibName2 owner:self topLevelObjects:&t2]){
					[self alertCriticalError:[NSString stringWithFormat:@"Could not load nib named: %@", nibName2] additional:nil];
					return nil;
				}
				_tloIP = t;
				_tloSPE = t2;
			} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				[NSBundle loadNibNamed:nibName1 owner:self];
				[NSBundle loadNibNamed:nibName2 owner:self];
#pragma clang diagnostic pop
			}
		}
		@catch (NSException *e) {
			[self alertCriticalException:e];
			return nil;
		}
	}

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

#pragma mark Alerting

- (int)showAlert:(NSAlertStyle)alertStyle message:(NSString*)msg additional:(NSString*)addMsg secondButton:(NSString*)secondButton thirdButton:(NSString*)thirdButton 
{
	int ret = 0;
	
	NSAlert *alert = [[NSAlert alloc] init];
	
	alert.alertStyle = alertStyle;
	[alert addButtonWithTitle: @"Ok"];
	alert.icon = [[NSImage alloc] initWithContentsOfFile:[myPlugin pluginIconPath]];
	alert.messageText = msg;
	if (addMsg != nil) {
		alert.informativeText = addMsg;		
	}
	if (secondButton != nil) {
		[alert addButtonWithTitle: secondButton];
	}
	if (thirdButton != nil) {
		[alert addButtonWithTitle: thirdButton];
	}
	int res = [alert runModal];
	if (res == NSAlertFirstButtonReturn) {
		ret = 1;
	}
	if (res == NSAlertThirdButtonReturn) {
		ret = 3;
	}
	return ret;
}


- (int)alertInformation:(NSString*)errMsg additional:(NSString*)addMsg thirdButton:(NSString*)thirdButton
{
	return [self showAlert:NSInformationalAlertStyle message:errMsg additional:addMsg secondButton:@"Cancel" thirdButton:thirdButton];
}

- (int)alertInformation:(NSString*)errMsg additional:(NSString*)addMsg cancelButton:(BOOL)yesorno
{
	if (yesorno) {
		return [self showAlert:NSInformationalAlertStyle message:errMsg additional:addMsg secondButton:@"Cancel" thirdButton:nil];
	}
	else {
		return [self showAlert:NSInformationalAlertStyle message:errMsg additional:addMsg secondButton:nil thirdButton:nil];
	}
}

- (void)alertCriticalError:(NSString*)errMsg additional:(NSString*)addMsg
{
	if ([self showAlert: NSCriticalAlertStyle message:errMsg additional:addMsg secondButton:@"Help" thirdButton:nil] != 1) {
		[myPlugin goToHelpWebsite];
	}
}

- (void)alertCriticalException:(NSException*)e
{
	[self alertCriticalError: NSLocalizedString(@"Sorry, we have an exception.",@"") additional:
		[[e.name stringByAppendingString:NSLocalizedString(@"\n\nReason:\n",@"") ] stringByAppendingString:e.reason]
	];
}

- (void)showInfoMessage:(NSString*)msg additional:(NSString*)additionalText
{
	[self showInfoMessage:msg additional:additionalText sticky:NO];
}

- (void)showInfoMessage:(NSString*)msg additional:(NSString*)additionalText sticky:(BOOL)isSticky
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUseGrowl]) {
		[self growlNotify:msg description:additionalText sticky:isSticky];
	}
	else {
			
		[self hideInfoMessage:NO];
		infoPanel.alphaValue = 1.0;
		infoText.stringValue = msg;
		infoTextAdditional.stringValue = additionalText;
		[infoPanel standardWindowButton:NSWindowCloseButton].hidden = !isSticky;
		
		// Calc text height
		NSTextView *utilityTextView = [[NSTextView alloc] initWithFrame:infoTextAdditional.frame];
		utilityTextView.string = additionalText;
		[utilityTextView.layoutManager glyphRangeForTextContainer:utilityTextView.textContainer]; // force layout
		CGFloat newHeight = NSHeight([utilityTextView.layoutManager usedRectForTextContainer:utilityTextView.textContainer]);
		
		NSRect r = NSMakeRect(infoPanel.frame.origin.x , infoPanel.frame.origin.y , infoPanel.frame.size.width, newHeight + infoPanel.contentMinSize.height);
		[infoPanel setFrame:r display:YES animate:YES];

		if (!isSticky) {
			panelTimer = [NSTimer scheduledTimerWithTimeInterval:PrefInfoPanelAfter target:self selector:@selector(hideInfoMessage:) userInfo:nil repeats:NO];
		}
		[infoPanel orderFront:self];
	}
}

- (void)hideInfoMessage:(BOOL)fadeout
{
	if (panelTimer != nil) {
		[panelTimer invalidate];
		panelTimer = nil;
	}
	if (infoPanel == nil || !infoPanel.visible) {
		return;
	}
	if (fadeout) {
		NSDictionary *myFadeOut = @{NSViewAnimationTargetKey: infoPanel,
									   NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect};

		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations: @[myFadeOut]];
		animation.animationBlockingMode = NSAnimationBlocking;
		animation.duration = PrefInfoPanelFadeout;
		[animation startAnimation];
	}
	[infoPanel close];
}


#pragma mark PHP-Errors

- (void)openSheetPhpError:(NSString*)error atLine:(int)lineOfError forWindow:(NSWindow*)window
{
	if ( window && !window.attachedSheet ) {
		phpErrorText.stringValue = error;
		lineOfErrorSaved = lineOfError;
		[NSApp beginSheet:sheetPhpError modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEndPhpError:returnCode:contextInfo:) contextInfo:nil];	
	}
	else {
		NSBeep();
	}
}

- (IBAction)goToPhpErrorLine:(id)sender
{
	[NSApp endSheet:sheetPhpError returnCode:NSOKButton];
}

- (IBAction)dismissPhpError:(id)sender
{
	[NSApp endSheet:sheetPhpError returnCode:NSCancelButton];	
}

- (void)sheetDidEndPhpError:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if ( returnCode == NSOKButton ) {
		[myPlugin goToLine:lineOfErrorSaved];
	}
	[sheet close];
}

#pragma mark Result Panel

- (void)showResult:(NSString *)data forUrl:(NSString *)baseurl withTitle:(NSString *)title
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefResultWindow]) {
		@try {
			NSString *nibName = @"ResultPanel";
			NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
			if([myBundle respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]){
				NSArray * t = nil;
				if(![myBundle loadNibNamed:nibName owner:self topLevelObjects:&t]){
					[self alertCriticalError:[NSString stringWithFormat:@"Could not load nib named: %@", nibName] additional:nil];
					return;
				}
				_tloRP = t;
			} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				[NSBundle loadNibNamed:nibName owner:self];
#pragma clang diagnostic pop
			}
		}
		@catch (NSException *exception) {
			[self alertCriticalException:exception];
			return;
		}

		resultLabel.stringValue = title;
		[resultView.mainFrame loadHTMLString:data baseURL:[NSURL URLWithString:baseurl]];
		[resultPanel makeKeyAndOrderFront:self];
	}
	else {
		[myPlugin displayHtmlString:data];		
	}
}

- (IBAction)clearResult:(id)sender
{
	/*
	[resultLabel setStringValue:@""];
	[[resultView mainFrame] loadHTMLString:@"<html><body>&nbsp;</body></html>" baseURL:[NSURL URLWithString:@"http://www.chipwreck.de"]];
	[[resultView superview] setNeedsDisplay:YES];
	[resultPanel update];
	*/
	[resultPanel close];
}

- (IBAction)closeResult:(id)sender
{
	[resultPanel close];
}

+ (NSString*)getCssForJsLint
{
	return @"<style type='text/css'>body{font-size:13px;font-family:sans-serif;line-height:1.25} h2{font-size:19px;} h2.warning{color:blue;} h2.error{color:red;} p{margin-bottom:0;} p.evidence,pre,code{line-height:1.1;color:#444;font-family:monospace;background:#f5f5f5;border:1px solid #ccc;font-size:12px;margin:2px 0 0 4px;padding:2px 4px;}</style>";
}
+ (NSString*)getCssForHtmlTidy
{
	return @"<style type='text/css'>pre{font-family:sans-serif;font-size: 13px;}</style><pre>";
}
+ (NSString*)getCssforValidatorNu
{
	return @"<style>*{font-family:sans-serif;font-size:13px;line-height:1.25;padding:0;margin:0}em,p span{color:#666}pre{margin-left:1em;font-family:monospace;font-size:11px;background-color:#eee;padding:0.25em;}pre span{font-family:monospace;font-size:11px;color:#822} p strong,p.success,p.errorsum{margin-top:0.5em;font-weight:bolder;} p.error strong{color:#822}p{font-size:13px;padding:1em;}p.success{background-color:green;color:white;}p.errorsum{background-color:red;color:white;}</style>";
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
}
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
}

#pragma mark Growl

- (void)growlNotify:(NSString *)title description:(NSString *)desc sticky:(BOOL)isSticky
{
	NSMutableArray *args = [NSMutableArray array];
	
	[args addObject:title];
	if (isSticky) {
		[args addObject:@"-s"];		
	}
	[args addObject:@"-m"];
	[args addObject:desc];
	[args addObject:@"-n"];
	[args addObject:@"Coda PHP & Web Toolkit"];
	[args addObject:@"--image"];
	[args addObject:[myPlugin pluginIconPath]];
	
	[myPlugin filterTextInput:@"" with:[myPlugin growlNotify] options:args encoding:NSUTF8StringEncoding useStdout:NO];
}

- (void)dealloc {
	_tloIP = nil;
	_tloRP = nil;
	_tloSPE = nil;
}

@end