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
	NSURLConnection *theConnection;
	PhpPlugin *myPlugin;
	NSMutableData *receivedData;
}
- (void)setMyPlugin:(PhpPlugin*)myPluginInstance;

- (void)checkForUpdateAuto;
- (NSString*)versioncheckUrl;
- (IBAction)downloadUpdate:(id)sender;
- (int)isUpdateAvailable;
- (void)isUpdateAvailableAsync;

@end
