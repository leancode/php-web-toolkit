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

+ (NSMutableString*)parse:(NSMutableString*)input
{
	return [NSMutableString stringWithString:[[HtmlTidyConfig getCssForHtmlTidy] stringByAppendingString:[HtmlTidyConfig escapeEntities:input]]];
}
+ (NSString*)getCssForHtmlTidy
{
	return @"<style type='text/css'>pre{font-family:sans-serif;font-size: 13px;}</style><pre>";
}
+ (NSString *)escapeEntities:(NSString *)inputString
{
	if (inputString == nil || [inputString length] == 0) {
		return @"";
	}
	NSMutableString *myString = [NSMutableString stringWithString:inputString];
	
    [myString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [myString length])];
	
    return myString;
}



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
	while ((aconfig = [configEnumerator nextObject]))
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
	return [[HtmlTidyConfig configForIntvalue:theencoding] retain];
}

@end
