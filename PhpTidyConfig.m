//
//  PhpTidyConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 24.01.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "PhpTidyConfig.h"


@implementation PhpTidyConfig

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = [[NSArray alloc] initWithObjects:
			[PhpTidyConfig configWithTitle:@"Always on new line" intvalue:0 cmdLine:@"n"],
            [PhpTidyConfig configWithTitle:@"Always on same line" intvalue:1 cmdLine:@"s"],
			[PhpTidyConfig configWithTitle:@"PEAR style" intvalue:2 cmdLine:@"p"],
		nil];
    }
    return configs;
}


+ (PhpTidyConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[PhpTidyConfig configArray] objectEnumerator];
	PhpTidyConfig *aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (PhpTidyConfig *)configForIndex:(int)theIdx
{
	return [[PhpTidyConfig configArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    PhpTidyConfig *newConfig = [[self alloc] init];
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
	return [[PhpTidyConfig configForIntvalue:theencoding] retain];
}

@end
