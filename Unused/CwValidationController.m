//
//  ValidationController.m
//  PhpPlugin
//
//  Created by mario on 14.04.11.
//

#import "CwValidationController.h"
#import "ValidationResult.h"
#import "PreferenceController.h"
#import "PhpPlugin.h"

@implementation CwValidationController

@synthesize error, result, errorMessage, inputData, encoding;

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


#pragma mark Filter

- (ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name useStdOut:(BOOL)usesstdout
{
	NSMutableString *resultText = [self filterTextInput:inputData with:command options:args encoding:encoding useStdout:usesstdout];
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
	
	/*
	if ([myResult error]) {
		//		[messageController alertInformation:[myResult errorMessage] additional:[myResult additional] cancelButton:NO];
	}	
	else if ([myResult valid] && show) {
		//		[messageController showInfoMessage:[name stringByAppendingString:NSLocalizedString(@": No errors",@"")] additional:resultText];
	}
	 */
	
	return [myResult autorelease];
}


- (NSString *)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name
{
	NSMutableString *resultText = [self filterTextInput:inputData with:command options:args encoding:encoding useStdout:YES];
	
	if (resultText == nil || [resultText length] < 6) {
		[self setError:YES];
		[self setErrorMessage:[[name stringByAppendingString:NSLocalizedString(@" nothing received.",@"")] stringByAppendingString: resultText]];
		return nil;
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"\nFatal"]) {
		[self setError:YES];
		[self setErrorMessage:[[name stringByAppendingString:NSLocalizedString(@" exception received.",@"")] stringByAppendingString: resultText]];
		return nil;
	}
	else if ([[resultText substringToIndex:6] isEqualToString:@"!ERROR"]) {
		[self setError:YES];
		[self setErrorMessage:[name stringByAppendingFormat:@": %@",[resultText substringFromIndex:1]]];
		return nil;
	}
	else {
		[self setError:NO];
		return resultText;
		//		[messageController showInfoMessage:[name stringByAppendingString:@" done"] additional:[@"File: " stringByAppendingString:[self currentFilename]]];
	}	
}


- (NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *dataIn;
	
	@try {
		dataIn = [textInput dataUsingEncoding: anEncoding];
		// [self doLog: [NSString stringWithFormat:@"in goes %@", textInput] ];
		
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
		
		[myPlugin doLog:[NSString stringWithFormat:@"Executing %@ at path %@ with %@", aTask, launchPath, cmdlineOptions] ];
		
		[aTask launch];
		[writing writeData:dataIn];
		[writing closeFile];
		
		if (anEncoding == NSUnicodeStringEncoding && [launchPath isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:PrefPhpLocal]]) {
			anEncoding = NSUTF8StringEncoding; // php binary never returns utf16..
			[myPlugin doLog:@"File was UTF-16 but php binary can't handle this correctly, so falling back to UTF-8"];
		}
		
		NSMutableString *resultData = [[NSMutableString alloc] initWithData: [reading readDataToEndOfFile] encoding: anEncoding];
		
		[aTask terminate];
		// [self doLog: [NSString stringWithFormat:@"Returned %@", resultData] ];
		[self setError:NO];
		return resultData;
	}
	@catch (NSException *e) {	
		[self setError:YES];
		[myPlugin doLog:[NSString stringWithFormat:@"Exception %@ %@ %@", [e name], [e description], [e reason]]];
		// [messageController alertCriticalException:e];
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
