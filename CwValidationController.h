//
//  ValidationController.h
//  PhpPlugin
//
//  Created by mario on 14.04.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhpPlugin, ValidationResult;

@interface CwValidationController : NSObject
{
@public
	BOOL error;
	NSMutableString *result;
	NSString *errorMessage;
	NSString *inputData;
	NSStringEncoding encoding;
	
@protected
	PhpPlugin *myPlugin;
}

@property BOOL error;
@property NSStringEncoding encoding;
@property (copy) NSMutableString *result;
@property (copy) NSString *errorMessage;
@property (copy) NSString *inputData;

-(void)setMyPlugin:(PhpPlugin *)myPluginInstance;

-(NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout;
-(NSString *)reformatWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name;
-(ValidationResult *)validateWith:(NSString *)command arguments:(NSMutableArray *)args called:(NSString *)name useStdOut:(BOOL)usesstdout;

@end
