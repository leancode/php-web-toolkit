//
//  PhpTidyConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 24.01.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "PhpTidyBLNConfig.h"


@implementation PhpTidyBLNConfig

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		NSMutableArray* m = [NSMutableArray array];
		for (int i = 1; i <= 8; i++) {
			NSString *r = [@(i) stringValue];
			[m addObject:[PhpTidyBLNConfig configWithTitle:r intvalue:(i-1) cmdLine:r]];
		}
		
		configs = [m copy];
    }
    return configs;
}


+ (PhpTidyBLNConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[PhpTidyBLNConfig configArray] objectEnumerator];
	PhpTidyBLNConfig *aconfig;
	while ((aconfig = [configEnumerator nextObject]))
	{
		if (theValue == aconfig.intvalue)
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (PhpTidyBLNConfig *)configForIndex:(int)theIdx
{
	return [PhpTidyBLNConfig configArray][theIdx];
}

/* Convenience constructor */
+ (instancetype)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    PhpTidyBLNConfig *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.cmdLineParam = aCmdLine;
    
    return newConfig;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger: intvalue forKey:@"encoding"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	int theencoding = 0;
	theencoding = [decoder decodeIntegerForKey:@"encoding"];
	return [PhpTidyBLNConfig configForIntvalue:theencoding];
}

@end
