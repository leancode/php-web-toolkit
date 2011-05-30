//
//  UpdateController.h
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PhpPlugin;

@interface UpdateController : NSObject
{	
	PhpPlugin *myPlugin;
	NSURLConnection *theConnection;	
	NSMutableData *receivedData;
}
- (void)setMyPlugin:(PhpPlugin*)myPluginInstance;

- (void)checkForUpdateAuto;
- (NSString*)versioncheckUrl;
- (NSString*)downloadUrl;
- (NSString*)directDownloadUrl;
- (NSString*)testDownloadUrl;
- (IBAction)downloadUpdate:(id)sender;
- (int)isUpdateAvailable;
- (void)isUpdateAvailableAsync;

@end
