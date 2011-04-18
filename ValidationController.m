//
//  ValidationController.m
//  PhpPlugin
//
//  Created by mario on 14.04.11.
//

#import "ValidationController.h"
#import "ValidationResult.h"

@implementation ValidationController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSStringEncoding)encoding
{
	return NSUTF8StringEncoding;
}
-(NSString*)input
{
	return @"";
}


#pragma mark Filter

- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name showResult:(BOOL)show useStdOut:(BOOL)usesstdout
{
	NSMutableString *resultText = [self filterTextInput:[self input] with:command options:args encoding:[self encoding] useStdout:usesstdout];
	
	ValidationResult* myResult = [[ValidationResult alloc] init];
	
	if (resultText == nil || [resultText length] == 0) {
		[myResult setError:YES];
		[myResult setErrorMessage:[name stringByAppendingString:NSLocalizedString(@" returned nothing",@"")]];
		[myResult setAdditional:NSLocalizedString(@"Make sure the file has no errors, try using UTF-8 encoding.",@"")];
	}
	else {
		[myResult setResult:resultText];
		
		if ([resultText rangeOfString:@"No warnings or errors were found"].location != NSNotFound || [resultText rangeOfString:@"No syntax errors detected"].location != NSNotFound) {
			[myResult setValid:YES];
		}
	}
	
	if ([myResult error]) {
		
	}	
	else if ([myResult valid] && show) {
		
	}
	
	return [myResult autorelease];
}

- (NSMutableString*)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name
{
	NSMutableString *resultText = [self filterTextInput:[self input] with:command options:args encoding:[self encoding] useStdout:YES];
	
	if (resultText == nil || [resultText length] < 6) {
		// ?
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"\nFatal"]) {
		// ?
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"!ERROR"]) {
		// ?
	}
	else {
		
	}
	return resultText;
}

- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *dataIn;
	
	@try {
		dataIn = [textInput dataUsingEncoding: anEncoding];
		
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
		
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData: [reading readDataToEndOfFile] encoding: anEncoding];
		
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
