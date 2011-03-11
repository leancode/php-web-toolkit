//
//  UpdateController.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "UpdateController.h"
#import "PreferenceController.h"
#import "PhpPlugin.h"

@implementation UpdateController

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (NSString *)versioncheckUrl
{
	return [@"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/versioncheck2.php?sw=codaphp&rnd=229&utm_source=updatecheck&utm_medium=plugin&utm_campaign=checkupdate&version=" stringByAppendingString: 
			[myPlugin pluginVersionNumber]];
}

- (void)checkForUpdateAuto
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PrefUpdateCheck]) {
		long lastupdate = [[NSUserDefaults standardUserDefaults] integerForKey:PrefLastUpdateCheck];
		long now = (long)[[NSDate date] timeIntervalSince1970];
		if (lastupdate == 0) {
			[self isUpdateAvailableAsync];
			[[NSUserDefaults standardUserDefaults] setInteger:now forKey:PrefLastUpdateCheck];
			[myPlugin doLog: [NSString stringWithFormat:@"Updatecheck: Pref for lastupdate not set, is now %u and did check", now]];
		}
		else {
			long timediff = (now - lastupdate);
			if (timediff > 86400) {
				[self isUpdateAvailableAsync];
				[[NSUserDefaults standardUserDefaults] setInteger:now forKey:PrefLastUpdateCheck];
				[myPlugin doLog: [NSString stringWithFormat:@"Updatecheck: Did check and set last update to %u", now]];
			}
		}
	}
	[self isUpdateAvailableAsync];
}

- (IBAction)downloadUpdate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [ NSURL URLWithString: [@"http://www.chipwreck.de/blog/wp-content/themes/chipwreck/download.php?sw=codaphp&utm_source=updatecheck&utm_medium=plugin&utm_campaign=downloadupdate&version=" stringByAppendingString:
																			 [myPlugin pluginVersionNumber]] ] ];
}

- (int)isUpdateAvailable
{
	int resultvalue = 2;
	NSURLRequest *request = [NSURLRequest
							 requestWithURL:[NSURL URLWithString:[self versioncheckUrl]]
							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
							 timeoutInterval:10];
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
							 timeoutInterval:10];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

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
	
	[connection release];
    [receivedData release];    
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
 
	[connection release];
	[receivedData release];
}


@end
