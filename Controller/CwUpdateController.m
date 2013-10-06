//
//  CwUpdateController.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "CwUpdateController.h"
#import "CwPreferenceController.h"
#import "CwPhpPlugin.h"

@implementation CwUpdateController

- (void)setMyPlugin:(CwPhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (NSString *)versioncheckUrl
{
	return [UrlVersionCheck stringByAppendingString: [myPlugin pluginVersionNumber]];
}

- (NSString *)downloadUrl
{
	return [UrlDownload stringByAppendingString: [myPlugin pluginVersionNumber]];
}

- (NSString *)directDownloadUrl
{
	return [UrlDownloadDirect stringByAppendingString: [myPlugin pluginVersionNumber]];
}

- (NSString *)testDownloadUrl
{
	return UrlDownloadTest;
}

- (void)checkForUpdateAuto
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUpdateCheck]) {
		long lastupdate = [[NSUserDefaults standardUserDefaults] integerForKey:PrefLastUpdateCheck];
		long now = (long)[[NSDate date] timeIntervalSince1970];
		long timediff = (now - lastupdate);
		if (lastupdate == 0 || timediff > PrefDelayUpdateCheck ) { // never or after three days
			[self isUpdateAvailableAsync];
			[[NSUserDefaults standardUserDefaults] setInteger:now forKey:PrefLastUpdateCheck];
			[myPlugin doLog: [NSString stringWithFormat:@"Updatecheck: Pref for lastupdate empty or expired, is now %lu and did check", now]];
		}
	}
}

- (IBAction)downloadUpdate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self downloadUrl]]];
}

- (int)isUpdateAvailable
{
	int resultvalue = 2;
	NSURLRequest *request = [NSURLRequest
							 requestWithURL:[NSURL URLWithString:[self versioncheckUrl]]
							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
							 timeoutInterval:PrefTimeoutNS];
	NSError *error;
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (!result) {
		[myPlugin doLog:[error localizedDescription]];
		resultvalue = 3;
	}
	else {
		NSString *displayString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
		[myPlugin doLog:[@"Response for versioncheck: " stringByAppendingString:displayString]];
		
		if (displayString != nil) {
			if ([ [displayString substringToIndex:7] isEqualToString:@"current"]) {
				resultvalue = 0;
			}
			else if ([ [displayString substringToIndex:6] isEqualToString:@"update"] ) {
				resultvalue = 1;
			}
			else if ([[displayString substringToIndex:4] isEqualToString:@"beta"]) {
				resultvalue = 0;
			}
			else {
				[myPlugin doLog:[@"Undefined response received while checking for updates: " stringByAppendingString:displayString]];
			}
		}
		else {
			resultvalue = 3;
		}
		[displayString release];
	}
	return resultvalue;
}

- (void)isUpdateAvailableAsync
{
	NSURLRequest *request = [NSURLRequest
							 requestWithURL:[NSURL URLWithString:[self versioncheckUrl]]
							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
							 timeoutInterval:PrefTimeoutNS];
	theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		[myPlugin doLog:@"Could not check for updates, maybe not connected to the internet?"];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[myPlugin doLog:[error localizedDescription]];
	
	[theConnection release];
	theConnection = nil;
    [receivedData release];
	receivedData = nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (!receivedData) {
		[myPlugin doLog:@"No data received while checking for update"];
	}
	else {
		NSString *displayString = [[NSString alloc] initWithData: receivedData encoding:NSUTF8StringEncoding];
		if (displayString != nil) {
			if ([ [displayString substringToIndex:7] isEqualToString:@"current"] || [[displayString substringToIndex:4] isEqualToString:@"beta"]) {
				[myPlugin doLog:@"You use the current version"];
			}
			else if ([ [displayString substringToIndex:6] isEqualToString:@"update"] ) {
				[myPlugin showUpdateAvailable];
			}
			else {
				[myPlugin doLog:[@"Undefined response received while checking for updates: " stringByAppendingString:displayString]];
			}
		}
		else {
			[myPlugin doLog:@"Could not check for updates - please make sure you're connected to the internet or try again later."];
		}
		[displayString release];
	}
 
	[theConnection release];
	theConnection = nil;
	[receivedData release];
	receivedData = nil;
}


@end
