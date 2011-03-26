//
//  Parser.h
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResultParser <NSObject>
+ (NSMutableString*)parse: (NSString*)input;
@end

@protocol InputParser <NSObject>
+ (NSMutableString*)parse: (NSString*)input;
@end


@interface NilParser: NSObject<InputParser>
	+ (NSMutableString*)parse: (NSString*)input;
@end

@implementation NilParser

+ (NSMutableString*)parse: (NSString*)input
{
	return [NSMutableString stringWithString:input];
}

@end