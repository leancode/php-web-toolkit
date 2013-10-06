//
//  CssTidyConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.01.10.
//  Copyright 2010 chipwreck.de. All rights reserved.
//

#import "CssTidyConfig.h"

@implementation CssTidyConfig

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = [[NSArray alloc] initWithObjects:
			[CssTidyConfig configWithTitle:@"Low Compression" intvalue:0 cmdLine:@"low_compression"],
            [CssTidyConfig configWithTitle:@"Default" intvalue:1 cmdLine:@"default"],
			[CssTidyConfig configWithTitle:@"Default, sorted" intvalue:4 cmdLine:@"default_sorted"],
            [CssTidyConfig configWithTitle:@"High Compression" intvalue:2 cmdLine:@"high_compression"],
            [CssTidyConfig configWithTitle:@"Highest Compression" intvalue:3 cmdLine:@"highest_compression"],
		nil];
    }
    return configs;
}


+ (CssTidyConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssTidyConfig configArray] objectEnumerator];
	CssTidyConfig * aconfig;
	while ((aconfig = [configEnumerator nextObject]))
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssTidyConfig *)configForIndex:(int)theIdx
{
	return [[CssTidyConfig configArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    CssTidyConfig *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.cmdLineParam = aCmdLine;
    
    return [newConfig autorelease];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger: intvalue forKey:@"encoding"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	int theencoding = 0;
	theencoding = [decoder decodeIntegerForKey:@"encoding"];
	return [[CssTidyConfig configForIntvalue:theencoding] retain];
}

@end
