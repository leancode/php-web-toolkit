//
//  Uploader.m
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "Uploader.h"
#import "zlib.h"

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";

@interface Uploader (Private)

- (void)upload;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data;
- (NSData *)compress: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end


@implementation Uploader

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
		filename = [anUploadfield retain];
		mimetype = [aFilename retain];
		delegate = [aDelegate retain];
		
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		
		serverReply = [[NSMutableString alloc] init];
		errorReply = [[NSMutableString alloc] init];
		
		[self upload];
	}
	return self;
}

- (void)dealloc
{
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

	doneSelector = NULL;
	errorSelector = NULL;
	
	[serverReply release];	
	[errorReply release];
	
	[super dealloc];
}

- (NSString *)errorReply
{
	return errorReply;
}
- (NSData *)contents
{
	return contents;
}
- (NSString *)serverReply
{
	return serverReply;
}

@end

@implementation Uploader (Private)

- (void)upload
{	
	if (!contents || [contents length] == 0) {
		[self uploadSucceeded:NO];
		return;
	}
	/*
	NSData *compressedData = [self compress:contents];
	if (!compressedData || [compressedData length] == 0) {
		[self uploadSucceeded:NO];
		return;
	}
	 */
	
	NSURLRequest *urlRequest = [self postRequestWithURL:serverURL
												boundry:BOUNDRY
												   data:contents];
	if (!urlRequest) {
		[self uploadSucceeded:NO];
		return;
	}
	
	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (!connection) {
		[self uploadSucceeded:NO];
	}
}

- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data
{
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];	
	[urlRequest setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [[NSMutableData alloc] initWithCapacity:512];
	NSArray* keys = [fields allKeys];

	for (unsigned i = 0; i < [keys count]; i++) 
	{
		id value = [fields valueForKey: [keys objectAtIndex: i]];
		[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[postData appendData: [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadfield, filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData: data];
	[postData appendData: [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[urlRequest setHTTPBody:postData];
	return urlRequest;
}

- (NSData *)compress: (NSData *)data
{
	if (!data || [data length] == 0)
		return nil;
	
	// zlib compress doc says destSize must be 1% + 12 bytes greater than source.
	uLong destSize = [data length] * 1.001 + 12;
	NSMutableData *destData = [NSMutableData dataWithLength:destSize];
	
	int cerror = compress([destData mutableBytes],
						 &destSize,
						 [data bytes],
						 [data length]);
	if (cerror != Z_OK) {
		[errorReply appendString:[NSString stringWithFormat:@" code: %d", cerror]];
		NSLog(@"%s: self:0x%p, zlib error on compress:%d\n",__func__, self, cerror);
		return nil;
	}
	
	[destData setLength:destSize];
	return destData;
}

- (void)uploadSucceeded: (BOOL)success
{
	[delegate performSelector:success ? doneSelector : errorSelector withObject:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[connection release];
	[self uploadSucceeded:uploadDidSucceed];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%s: self:0x%p, connection error:%s\n", __func__, self, [[error description] UTF8String]);
	[errorReply appendString:[error localizedDescription]];
	[connection release];
	[self uploadSucceeded:NO];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[serverReply appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	uploadDidSucceed = YES;
}


@end
