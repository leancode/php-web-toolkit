//
//  ValidationResult.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "ValidationResult.h"


@implementation ValidationResult

@synthesize valid, result, additional;

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		valid = NO;
	}

	return self;
}

-(BOOL)hasErrorMessage
{
	return ![self valid] && [self hasResult];
}

-(BOOL)hasResult
{
	return ([self result] != nil && [[self result] length] > 0);
}

@end
