//
//  Uploader.m
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "RequestController.h"
#import "PhpPlugin.h"

static NSString* const BOUNDRY = @"0xKhTmLbOuNdArY";

@interface RequestController(private)

- (void)upload;
- (BOOL)uploadReturn;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                                data: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;

@end

@implementation RequestController

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (id)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
         delegate: (id)aDelegate
     doneSelector: (SEL)aDoneSelector
    errorSelector: (SEL)anErrorSelector
{
	if ((self = [super init])) {
		serverURL = [aServerURL retain];
		contents = [aData retain];
		fields = [aFields retain];
		uploadfield = [anUploadfield retain];
		filename = [aFilename retain];
		mimetype = [aMimetype retain];
		delegate = [aDelegate retain];
		
		[self setMyPlugin:delegate];
		
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		
		serverReply = [[NSMutableString alloc] init];
		errorReply = [[NSMutableString alloc] init];
		
		[self upload];
	}
	return self;
}

- (id)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
{
	if ((self = [super init])) {
		serverURL = [aServerURL retain];
		contents = [aData retain];
		fields = [aFields retain];
		uploadfield = [anUploadfield retain];
		filename = [aFilename retain];
		mimetype = [aMimetype retain];
		delegate = self;
		
		[self setMyPlugin:delegate];
		
		serverReply = [[NSMutableString alloc] init];
		errorReply = [[NSMutableString alloc] init];
	}
	return self;
}

- (BOOL)doUpload
{
	return [self uploadReturn];
}

- (void)dealloc
{
	@try {
		[serverURL release];
		serverURL = nil;
		[contents release];
		contents = nil;
		[fields release];
		fields = nil;
		[uploadfield release];
		uploadfield = nil;
		[filename release];
		filename = nil;
		[mimetype release];
		mimetype = nil;	
		[delegate release];
		delegate = nil;

		// [serverReply release];	
		// [errorReply release];

		doneSelector = NULL;
		errorSelector = NULL;
	}
	@catch (NSException *e) {
		[myPlugin doLog:[@"Exception in RequestController:dealloc:" stringByAppendingFormat:@"%@", e]];
	}
	
	[super dealloc];
}

- (NSString *)errorReply
{
	return errorReply;
}

- (NSString *)serverReply
{
	return serverReply;
}

@end

@implementation RequestController (private)

- (BOOL)uploadReturn
{	
	if (!contents || [contents length] == 0) {
		[errorReply setString: @"No input received"];
		return NO;
	}
	
	NSURLRequest *urlRequest = [self postRequestWithURL:serverURL data:contents];
	if (!urlRequest) {
		[errorReply setString: @"Request could not be initialized"];
		return NO;
	}
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (!connection) {
		[errorReply setString: @"Connection could not be initialized"];
		return NO;
	}
	[myPlugin doLog:[@"Init Connection to " stringByAppendingString:[serverURL absoluteString]]];
	
	NSError *error;
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if (!result) {
		errorReply = [NSMutableString stringWithString:[error localizedDescription]];
		return NO;
	}
	serverReply = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	return YES;
}

- (void)upload
{
	[self uploadSucceeded:[self uploadReturn]];
}

- (void)uploadSucceeded: (BOOL)success
{
	[delegate performSelector:success ? doneSelector : errorSelector withObject:self];
}

- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                                data: (NSData *)data
{
	@try {
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		NSMutableData *postData = [[NSMutableData alloc] initWithCapacity:512];
		NSArray* keys = [fields allKeys];
		
		[urlRequest setHTTPMethod:@"POST"];	
		[urlRequest setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDRY] forHTTPHeaderField:@"Content-Type"];

		for (unsigned i = 0; i < [keys count]; i++) 
		{
			[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithFormat:@"%@",[fields valueForKey: [keys objectAtIndex: i]]] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[postData appendData: [[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadfield, filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: data];
		[postData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		

		[postData appendData: [[NSString stringWithFormat:@"--%@--\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
		[urlRequest setHTTPBody:postData];
		
		[myPlugin doLog:[[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding]];
		
		return urlRequest;
	}
	@catch (NSException *e) {
		[myPlugin doLog:[@"Exception in RequestController:postRequest:" stringByAppendingFormat:@"%@", e]];
		
	}
	return nil;
}

@end
