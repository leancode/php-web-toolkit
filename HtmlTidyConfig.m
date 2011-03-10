//
//  HtmlTidyConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 22.01.10.
//  Copyright 2010 chipwreck.de. All rights reserved.
//

#import "HtmlTidyConfig.h"

@implementation HtmlTidyConfig

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = [[NSArray alloc] initWithObjects:
			[HtmlTidyConfig configWithTitle:@"Very Indented" intvalue:0 cmdLine:@"indented"],
            [HtmlTidyConfig configWithTitle:@"Default" intvalue:1 cmdLine:@"default"],
            [HtmlTidyConfig configWithTitle:@"Wrapped" intvalue:2 cmdLine:@"wrapped"],
            [HtmlTidyConfig configWithTitle:@"High Compression" intvalue:3 cmdLine:@"compressed"],
			[HtmlTidyConfig configWithTitle:@"Body only (experimental)" intvalue:4 cmdLine:@"bodyonly"],
			[HtmlTidyConfig configWithTitle:@"Custom..." intvalue:5 cmdLine:@"custom"],
		nil];
    }
    return configs;
}

+ (HtmlTidyConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[HtmlTidyConfig configArray] objectEnumerator];
	HtmlTidyConfig * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (HtmlTidyConfig *)configForIndex:(int)theIdx
{
	return [[HtmlTidyConfig configArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    HtmlTidyConfig *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.cmdLineParam = aCmdLine;
    
    return newConfig;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger: intvalue forKey:@"encoding"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	int theencoding = 0;
	theencoding = [decoder decodeIntegerForKey:@"encoding"];
	return [HtmlTidyConfig configForIntvalue:theencoding];
}

@end
