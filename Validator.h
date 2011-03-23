//
//  Validator.h
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValidationResult.h"

@interface Validator : NSObject
{
@private

@public
	NSString* name;
	NSDictionary* args;
	BOOL synchronous;	
	id command;
	id inputParser;
	id outputParser;
}

@property BOOL synchronous;
@property (copy) NSString *name;
@property (copy) NSDictionary *args;
@property (copy) id command;
@property (copy) id inputParser;
@property (copy) id outputParser;

-(ValidationResult*)validate;

@end
