//
//  Validator.m
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "Validator.h"


@implementation Validator

@synthesize synchronous, name, args, command, inputParser, outputParser;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (id)initWithCommand:(id)cmd Arguments:(NSDictionary*)args
{
	Validator* myself = [[Validator alloc] init];
	[myself setCommand:cmd];
	[myself setArgs:args];
	return self;
}

-(ValidationResult*)validate
{
	NSMutableString *resultText = [NSMutableString stringWithString:@""]; // [self filterTextInput:[self getEditorText] with:command options:args encoding:[[controller focusedTextView:self] encoding] useStdout:usesstdout];
	
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
	else if ([myResult valid]) {
	}
	
	return [myResult autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

@end
