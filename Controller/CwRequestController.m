//
//  Uploader.m
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//

#import "CwRequestController.h"
#import "CwPhpPlugin.h"

static NSString* const BOUNDRY = @"0xKhTmLbOuNdArY";

@interface CwRequestController ()
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

@interface CwRequestController(private)

- (void)upload;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL uploadReturn;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                                data: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;

@end

@implementation CwRequestController

- (instancetype)init { @throw nil; }

- (instancetype)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
         delegate: (id<CwPhpPluginDelegate>)aDelegate
{
	if ((self = [super init])) {
		serverURL = aServerURL;
		contents = aData;
		fields = aFields;
		uploadfield = anUploadfield;
		filename = aFilename;
		mimetype = aMimetype;
		delegate = aDelegate;
		
		serverReply = [[NSMutableString alloc] init];
		errorReply = [[NSMutableString alloc] init];
		
		[self upload];
	}
	return self;
}

- (instancetype)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
{
	if ((self = [super init])) {
		serverURL = aServerURL;
		contents = aData;
		fields = aFields;
		uploadfield = anUploadfield;
		filename = aFilename;
		mimetype = aMimetype;
		delegate = nil;
		
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
		serverURL = nil;
		contents = nil;
		fields = nil;
		uploadfield = nil;
		filename = nil;
		mimetype = nil;

		// [serverReply release];	
		// [errorReply release];
	}
	@catch (NSException *e) {
		[delegate doLog:[@"Exception in RequestController:dealloc:" stringByAppendingFormat:@"%@", e]];
	}
	
	delegate = nil;
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

@implementation CwRequestController (private)

- (BOOL)uploadReturn
{	
	if (!contents || contents.length == 0) {
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
	//[delegate doLog:[@"Init Connection to " stringByAppendingString:[serverURL absoluteString]]];
	
	NSError *error;
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if (!result) {
		errorReply = [NSMutableString stringWithString:error.localizedDescription];
		return NO;
	}
	serverReply = [[NSMutableString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	// [delegate doLog:[@"Server replied: " stringByAppendingString:serverReply]];
	return YES;
}

- (void)upload
{
	[self uploadSucceeded:[self uploadReturn]];
}

- (void)uploadSucceeded: (BOOL)success
{
	if(success){
		[delegate done:self];
	} else {
		[delegate error:self];
	}
}

- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                                data: (NSData *)data
{
	@try {
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		NSMutableData *postData = [[NSMutableData alloc] initWithCapacity:512];
		NSArray* keys = fields.allKeys;
		
		urlRequest.HTTPMethod = @"POST";	
		[urlRequest setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDRY] forHTTPHeaderField:@"Content-Type"];

		for (unsigned i = 0; i < keys.count; i++) 
		{
			[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keys[i]] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithFormat:@"%@",[fields valueForKey: keys[i]]] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[postData appendData: [[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadfield, filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData: data];
		[postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		

		[postData appendData: [[NSString stringWithFormat:@"--%@--\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
		urlRequest.HTTPBody = postData;
		
		[delegate doLog:[[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]];
		
		return urlRequest;
	}
	@catch (NSException *e) {
		[delegate doLog:[@"Exception in RequestController:postRequest:" stringByAppendingFormat:@"%@", e]];
		
	}
	return nil;
}

@end
