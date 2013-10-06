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

- (void)setEncoding: (Encoding*)anEncoding
{
	encoding = anEncoding;
}

- (Encoding*)getEncoding
{
	return encoding;
}


-(NSArray*)getArgs
{
	return [NSArray arrayWithObjects:nil];
}

-(NSString*)getCmdline;
{
	return @"";
}

@end
