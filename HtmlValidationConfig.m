//
//  HtmlValidationConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "HtmlValidationConfig.h"
#import "HtmlTidyConfig.h"
#import "MessagingController.h"

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
				   [HtmlValidationConfig configWithTitle:@"Validator.nu" intvalue:2 url:@"http://html5.validator.nu" fieldname:@"file"],
		nil];
    }
    return configs;
}

+ (HtmlValidationConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[HtmlValidationConfig configArray] objectEnumerator];
	HtmlValidationConfig *aconfig;
	while ((aconfig = [configEnumerator nextObject]))
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
	while ((aconfig = [configEnumerator nextObject]))
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

+ (NSMutableString*)parseValidatorNuOutput:(NSMutableDictionary*)jsonResult
{
	NSMutableString *resultFromJson = [NSMutableString stringWithString:@""];
	if (jsonResult != nil) {
		
		if ([jsonResult isKindOfClass:[NSDictionary class]]) {
			if ([jsonResult objectForKey:@"messages"] != nil) {
				int numErrors = 0;
				for (NSDictionary *dict in [jsonResult objectForKey:@"messages"]) {
					if ([[dict objectForKey:@"type"] isEqualToString:@"error"]) {
						numErrors++;
					}
					
					[resultFromJson appendFormat:@"<p class=\"%@\">", [dict objectForKey:@"type"]];
					if ([dict objectForKey:@"lastLine"] != nil) {
						[resultFromJson appendFormat:@"<span>Line %@",[dict objectForKey:@"lastLine"]];
						if ([dict objectForKey:@"firstColumn"] != nil) {
							[resultFromJson appendFormat:@", column %@",[dict objectForKey:@"firstColumn"]];
						}
						[resultFromJson appendString:@"</span>"];
					} 
					[resultFromJson appendFormat:@" <strong>%@:</strong> %@</p>", [dict objectForKey:@"type"], [HtmlTidyConfig escapeEntities:[dict objectForKey:@"message"]]];
					
					if ([dict objectForKey:@"extract"] != nil) {
						if ([dict objectForKey:@"hiliteStart"] != nil && [dict objectForKey:@"hiliteLength"] != nil && [[dict objectForKey:@"hiliteLength"] intValue] > 0) {
							NSString *extract1 = [[dict objectForKey:@"extract"] substringToIndex:[[dict objectForKey:@"hiliteStart"] intValue]];
							NSString *extract2 = [[dict objectForKey:@"extract"] substringWithRange:NSMakeRange([[dict objectForKey:@"hiliteStart"] intValue],[[dict objectForKey:@"hiliteLength"] intValue])];
							NSString *extract3 = [[dict objectForKey:@"extract"] substringFromIndex:[[dict objectForKey:@"hiliteStart"] intValue] + [[dict objectForKey:@"hiliteLength"] intValue]];
							[resultFromJson appendFormat:@"<pre>%@<span>%@</span>%@</pre>",[HtmlTidyConfig escapeEntities:extract1], [HtmlTidyConfig escapeEntities:extract2], [HtmlTidyConfig escapeEntities:extract3]];
						}
						else {
							[resultFromJson appendFormat:@"<pre>%@</pre>",[HtmlTidyConfig escapeEntities:[dict objectForKey:@"extract"]]];
						}
					}								
				}
				if (numErrors == 0) {
					[resultFromJson appendString:@"<p class=\"success\">No errors.</p>"];
				}
				else {
					[resultFromJson appendFormat:@"<p class=\"errorsum\">%u errors.</p>", numErrors];
				}
			}
		}
	}
	return resultFromJson;
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
