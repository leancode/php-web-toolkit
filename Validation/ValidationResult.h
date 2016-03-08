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
	BOOL error;
	NSMutableString *result;
	NSString *errorMessage;
	NSString *additional;
}

@property BOOL valid;
@property BOOL error;
@property (copy) NSMutableString *result;
@property (copy) NSString *errorMessage;
@property (copy) NSString *additional;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasResult;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasFailResult;

@end
