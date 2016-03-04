//
//  CwDownloadController.h
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//

#import <Foundation/Foundation.h>

@class CwPhpPlugin;

extern NSString* const TmpUpdateFile;
extern NSString* const TmpUnpackedFile;

@interface CwDownloadController : NSWindowController <NSURLDownloadDelegate>
{
	CwPhpPlugin *myPlugin;
	NSString *downloadUrl;
	NSString *downloadFilename;
	NSString *downloadPath;
	NSBox *progressBox;
	NSURLResponse *downloadResponse;
	NSURLDownload *theDownload;
	int64_t bytesReceived;
	
	IBOutlet NSPanel *downloadPanel;
	IBOutlet NSTextField *responseLabel;
	IBOutlet NSButton *downloadWebButton;
	IBOutlet NSButton *updateButton;
	IBOutlet NSProgressIndicator *progressIndicator;
}

@property (copy) NSString *downloadUrl;
@property (copy) NSString *downloadFilename;
@property (copy) NSString *downloadPath;
@property (copy) NSURLDownload *theDownload;
@property (copy) NSURLResponse *downloadResponse;
@property (copy) NSArray *tlo;

- (void)setMyPlugin:(CwPhpPlugin *)myPluginInstance;
- (void)showPanelWithUrl:(NSString*)url;
- (void)reportError:(NSString*)err additional:(NSString*)additional;
- (IBAction)startDownload:(id)sender;
- (IBAction)closePanel:(id)sender;
- (IBAction)extractAndInstall:(id)sender;
- (IBAction)downloadWebsite:(id)sender;

@end
