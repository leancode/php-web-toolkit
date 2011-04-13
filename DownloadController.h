//
//  DownloadController.h
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhpPlugin;

extern NSString* const TmpUpdateFile;
extern NSString* const TmpUnpackedFile;

@interface DownloadController : NSWindowController
{
	PhpPlugin *myPlugin;
	NSString *downloadUrl;
	NSString *downloadFilename;
	NSString *downloadPath;
	NSURLResponse *downloadResponse;
	NSURLDownload *theDownload;
	int64_t bytesReceived;
	
	IBOutlet NSPanel *downloadPanel;
	IBOutlet NSTextField *responseLabel;
	IBOutlet NSButton *downloadWebButton;
	IBOutlet NSProgressIndicator *progressIndicator;
}

@property (copy) NSString *downloadUrl;
@property (copy) NSString *downloadFilename;
@property (copy) NSString *downloadPath;
@property (copy) NSURLDownload *theDownload;
@property (copy) NSURLResponse *downloadResponse;

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance;
- (void)startDownloadingURL:(NSString*)url;
- (void)reportError:(NSString*)err;
- (IBAction)extractAndInstall:(id)sender;
- (IBAction)downloadWebsite:(id)sender;

@end
