//
//  CwUpdateController.h
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CwPhpPlugin;

@interface CwUpdateController : NSObject
{	
	CwPhpPlugin *myPlugin;
	NSURLConnection *theConnection;	
	NSMutableData *receivedData;
}
- (void)setMyPlugin:(CwPhpPlugin*)myPluginInstance;

- (void)checkForUpdateAuto;
- (NSString*)versioncheckUrl;
- (NSString*)downloadUrl;
- (NSString*)directDownloadUrl;
- (NSString*)testDownloadUrl;
- (IBAction)downloadUpdate:(id)sender;
- (int)isUpdateAvailable;
- (void)isUpdateAvailableAsync;

@end
