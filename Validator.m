//
//  Validator.m
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "Validator.h"
#import "RequestController.h"


@implementation Validator

@synthesize synchronous, name, args, command, inputParser, resultParser;

- (id)init
{
	[super init];
	[self setName:[self className]];
	return self;
}

- (id)initWithCommand:(NSURL*)cmd arguments:(NSMutableArray*)options
{
	if (![super init]) {
		return nil;
	}
	[self setCommand:cmd];
	[self setArgs:options];
	return self;
}

-(ValidationResult*)validate:(NSString*)input encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout
{
	if (resultParser == nil) {
		[self setResultParser:[[NilParser alloc] init]];
	}
	if (inputParser == nil) {
		[self setInputParser:[[NilParser alloc] init]];
	}
	
	if ([command isFileURL]) {
		return [self validateCmdline:[inputParser parse:input] cmd:[command path] encoding:encoding useStdout:useout];
	}
	else {
		return [self validateOnline:[inputParser parse:input] url:[command baseURL] encoding:encoding uploadField:[command fragment] filename:[command user] mime:[command password]];
	}
}


-(ValidationResult*)validateOnline:(NSString*)input url:(NSURL*)url encoding:(NSStringEncoding)encoding uploadField:(NSString*)field filename:(NSString*)filename mime:(NSString*)mimetype
{
	RequestController *myreq = [[[RequestController alloc] initWithURL:url
															  contents:[input dataUsingEncoding:encoding]
																fields:[NSMutableDictionary dictionaryWithObjects:args forKeys:nil]
														   uploadfield:field
															  filename:filename
															  mimetype:mimetype
															 ] autorelease];
	
	ValidationResult* myResult = [[ValidationResult alloc] init];
	if (![myreq doUpload]) {
		[myResult setError:YES];
		[myResult setErrorMessage:[myreq errorReply]];
	}
	else {
		NSMutableString *resultText = [resultParser parse:[myreq serverReply]];
		if (resultText == nil || [resultText length] == 0) {
			[myResult setError:YES];
			[myResult setErrorMessage:[myreq errorReply]];
		}
		else {
			[myResult setValid:YES]; //?
			[myResult setResult:resultText];
		}
	}
	return myResult;
}


-(ValidationResult*)validateCmdline:(NSString*)input cmd:(NSString*)cmd encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout
{
	NSMutableString *resultText = [resultParser parse:[self filterTextInput:[inputParser parse:input] with:cmd options:args encoding:encoding useStdout:useout]];
	
	ValidationResult* myResult = [[ValidationResult alloc] init];
	
	if (resultText == nil || [resultText length] == 0) {
		[myResult setError:YES];
		[myResult setErrorMessage:[name stringByAppendingString:NSLocalizedString(@" returned nothing",@"")]];
	}
	else {
		[myResult setResult:resultText];
		
		if ([resultText rangeOfString:@"No warnings or errors were found"].location != NSNotFound || [resultText rangeOfString:@"No syntax errors detected"].location != NSNotFound) {
			[myResult setValid:YES];
		}
	}

	return [myResult autorelease];
}

- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *dataIn;
	
	@try {
		dataIn = [textInput dataUsingEncoding: encoding];
		
		NSPipe *toPipe = [NSPipe pipe];
		NSPipe *fromPipe = [NSPipe pipe];
		NSPipe *errPipe = [NSPipe pipe];
		NSFileHandle *writing = [toPipe fileHandleForWriting];
		NSFileHandle *reading;	
		if (useout) {
			reading = [fromPipe fileHandleForReading];
		}
		else {
			reading = [errPipe fileHandleForReading];		
		}
		
		[aTask setStandardInput:toPipe];
		[aTask setStandardOutput:fromPipe];
		[aTask setStandardError:errPipe];
		[aTask setArguments:cmdlineOptions];
		[aTask setLaunchPath:launchPath];
		
		// [self doLog: [NSString stringWithFormat:@"Executing %@ at path %@ with %@", aTask, launchPath, cmdlineOptions] ];
		
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData:[reading readDataToEndOfFile] encoding:encoding];
		
		[aTask terminate];
		//		[self doLog: [NSString stringWithFormat:@"Returned %@", resultData] ];
		return resultData;
	}
	@catch (NSException *e) {
		//		[messageController alertCriticalException:e];
		return nil;
	}
	@finally {
		[aTask release];
	}
	
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
