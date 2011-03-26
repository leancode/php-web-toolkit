//
//  Validator.h
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValidationResult.h"
#import "Parser.h"

@interface Validator : NSObject
{
@private

@public
	NSString* name;
	NSMutableArray* args;
	BOOL synchronous;	
	NSURL* command;
	id<InputParser> inputParser;
	id<ResultParser> resultParser;
}

@property BOOL synchronous;
@property (copy) NSString *name;
@property (copy) NSMutableArray *args;
@property (copy) NSURL *command;
@property (copy) id inputParser;
@property (copy) id resultParser;


-(id)initWithCommand:(NSURL *)cmd arguments:(NSMutableArray *)options;
-(NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout;

-(ValidationResult*)validate:(NSString*)input encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout;

-(ValidationResult*)validateCmdline:(NSString*)input cmd:(NSString*)cmd encoding:(NSStringEncoding)encoding useStdout:(BOOL)useout;
-(ValidationResult*)validateOnline:(NSString*)input url:(NSURL*)url encoding:(NSStringEncoding)encoding uploadField:(NSString*)field filename:(NSString*)filename mime:(NSString*)mimetype;

@end
