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
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *versioncheckUrl;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *downloadUrl;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *directDownloadUrl;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *testDownloadUrl;
- (IBAction)downloadUpdate:(id)sender;
@property (NS_NONATOMIC_IOSONLY, getter=isUpdateAvailable, readonly) int updateAvailable;
- (void)isUpdateAvailableAsync;

@end
