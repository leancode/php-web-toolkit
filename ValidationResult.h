//
//  ValidationResult.h
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ValidationResult : NSObject 
{
@public
    BOOL valid;
    NSMutableString *result;
	NSString *additional;
}

@property BOOL valid;
@property (copy) NSMutableString *result;
@property (copy) NSString *additional;

-(BOOL)hasResult;
-(BOOL)hasErrorMessage;

@end
