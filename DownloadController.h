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
extern NSString* const DownloadUrl;

@interface DownloadController : NSWindowController
{
	PhpPlugin *myPlugin;
	NSURLResponse *downloadResponse;
	int64_t bytesReceived;
	
	IBOutlet NSPanel *downloadPanel;
	IBOutlet NSButton *doneButton;
	IBOutlet NSTextField *responseLabel;
	IBOutlet NSProgressIndicator *progressIndicator;
}

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance;
- (void)startDownloadingURL:sender;
- (IBAction)doneButtonPushed: (id)sender;

@end
