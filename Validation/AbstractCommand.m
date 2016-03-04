//
//  AbstractConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 10.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "AbstractCommand.h"


@implementation AbstractCommand

- (void)setLineEnding: (NSString*)aLineEnding
{
	lineEnding = aLineEnding;
}

- (NSString*)getLineEnding;
{
	return lineEnding;
}

- (void)setEncoding: (CwEncoding*)anEncoding
{
	encoding = anEncoding;
}

- (CwEncoding*)getEncoding
{
	return encoding;
}


-(NSArray*)getArgs
{
	return @[];
}

-(NSString*)getCmdline;
{
	return @"";
}

@end
