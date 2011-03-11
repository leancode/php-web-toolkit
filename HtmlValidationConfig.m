//
//  HtmlValidationConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "HtmlValidationConfig.h"


@implementation HtmlValidationConfig

@synthesize intvalue, title, validationUrl, validationFieldname;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = [[NSArray alloc] initWithObjects:
				   [HtmlValidationConfig configWithTitle:@"W3C Validator" intvalue:0 url:@"http://validator.w3.org/check" fieldname:@"uploaded_file"],
				   [HtmlValidationConfig configWithTitle:@"Unicorn Validator" intvalue:1 url:@"http://validator.w3.org/unicorn/check" fieldname:@"ucn_file"],
				   [HtmlValidationConfig configWithTitle:@"W3C Validator" intvalue:2 url:@"http://validator.nu" fieldname:@"file"],
		nil];
    }
    return configs;
}

+ (HtmlValidationConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[HtmlValidationConfig configArray] objectEnumerator];
	HtmlValidationConfig *aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (HtmlValidationConfig *)configForUrl:(NSString*)theUrl
{
	NSEnumerator *configEnumerator = [[HtmlValidationConfig configArray] objectEnumerator];
	HtmlValidationConfig *aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if ([theUrl isEqualToString:[aconfig validationUrl]])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (HtmlValidationConfig *)configForIndex:(int)theIdx
{
	return [[HtmlValidationConfig configArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue url:(NSString *)anUrl fieldname:(NSString*)aFieldname
{
    HtmlValidationConfig *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.validationUrl = anUrl;
	newConfig.validationFieldname = aFieldname;
    
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
	return [[HtmlValidationConfig configForIntvalue:theencoding] retain];
}

@end
