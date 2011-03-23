//
//  CssLevel.m
//  PhpPlugin
//
//  Created by Mario Fischer on 08.01.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "CssLevel.h"


@implementation CssLevel

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = [[NSArray alloc] initWithObjects:
			[CssLevel configWithTitle:@"Level 2" intvalue:0 cmdLine:@"css2"],
            [CssLevel configWithTitle:@"Level 2.1" intvalue:1 cmdLine:@"css21"],
			[CssLevel configWithTitle:@"Level 3" intvalue:2 cmdLine:@"css3"],
		nil];
    }
    return configs;
}


+ (CssLevel *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssLevel configArray] objectEnumerator];
	CssLevel *aconfig;
	while ((aconfig = [configEnumerator nextObject]))
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssLevel *)configForIndex:(int)theIdx
{
	return [[CssLevel configArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    CssLevel *newConfig = [[self alloc] init];
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
	return [[CssLevel configForIntvalue:theencoding] retain];
}

@end
