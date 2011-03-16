//
//  RequestController.m
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "RequestController.h"
#import "PhpPlugin.h"

@implementation RequestController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (void)startRequest:(NSString*)anurl
{
	myUrl = [NSMutableString stringWithString:anurl];
	NSURLRequest *request = [NSURLRequest
							 requestWithURL:[NSURL URLWithString:myUrl]
							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
							 timeoutInterval:10];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		[myPlugin doLog:[@"Could not start request to " stringByAppendingString:myUrl]];
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
		[myPlugin doLog:[@"No data received for " stringByAppendingString:myUrl]];
	}
	else {
		NSString *displayString = [[NSString alloc] initWithData: receivedData encoding:NSUTF8StringEncoding];
		if (displayString != nil) {
		}
		else {
			[myPlugin doLog:[@"Could not connect to " stringByAppendingString:myUrl]];
		}
		[displayString release];
	}
	
	[connection release];
	[receivedData release];
}

- (void)dealloc
{
    [super dealloc];
}

@end
