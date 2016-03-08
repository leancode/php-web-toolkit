//
//  HtmlValidationConfig.m
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "HtmlValidationConfig.h"
#import "HtmlTidyConfig.h"
#import "CwMessagingController.h"

@implementation HtmlValidationConfig

@synthesize intvalue, title, validationUrl, validationFieldname;

/* Predefined global list of configs */
+ (NSArray*)configArray
{
    static NSArray *configs;
    if (!configs)
    {
		configs = @[[HtmlValidationConfig configWithTitle:@"W3C Validator" intvalue:0 url:@"http://validator.w3.org/check" fieldname:@"uploaded_file"],
				   [HtmlValidationConfig configWithTitle:@"Unicorn Validator" intvalue:1 url:@"http://validator.w3.org/unicorn/check" fieldname:@"ucn_file"],
				   [HtmlValidationConfig configWithTitle:@"Validator.nu" intvalue:2 url:@"http://html5.validator.nu" fieldname:@"file"]];
    }
    return configs;
}

+ (HtmlValidationConfig *)configForIntvalue:(int)theValue
{
	NSEnumerator *configEnumerator = [[HtmlValidationConfig configArray] objectEnumerator];
	HtmlValidationConfig *aconfig;
	while ((aconfig = [configEnumerator nextObject]))
	{
		if (theValue == aconfig.intvalue)
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
		if ([theUrl isEqualToString:aconfig.validationUrl])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (HtmlValidationConfig *)configForIndex:(int)theIdx
{
	return [HtmlValidationConfig configArray][theIdx];
}

+ (NSMutableString*)parseValidatorNuOutput:(NSMutableDictionary*)jsonResult
{
	NSMutableString *resultFromJson = [NSMutableString stringWithString:@""];
	if (jsonResult != nil) {
		
		if ([jsonResult isKindOfClass:[NSDictionary class]]) {
			if (jsonResult[@"messages"] != nil) {
				int numErrors = 0;
				for (NSDictionary *dict in jsonResult[@"messages"]) {
					if ([dict[@"type"] isEqualToString:@"error"]) {
						numErrors++;
					}
					
					[resultFromJson appendFormat:@"<p class=\"%@\">", dict[@"type"]];
					if (dict[@"lastLine"] != nil) {
						[resultFromJson appendFormat:@"<span>Line %@",dict[@"lastLine"]];
						if (dict[@"firstColumn"] != nil) {
							[resultFromJson appendFormat:@", column %@",dict[@"firstColumn"]];
						}
						[resultFromJson appendString:@"</span>"];
					} 
					[resultFromJson appendFormat:@" <strong>%@:</strong> %@</p>", dict[@"type"], [HtmlTidyConfig escapeEntities:dict[@"message"]]];
					
					if (dict[@"extract"] != nil) {
						if (dict[@"hiliteStart"] != nil && dict[@"hiliteLength"] != nil && [dict[@"hiliteLength"] intValue] > 0) {
							NSString *extract1 = [dict[@"extract"] substringToIndex:[dict[@"hiliteStart"] intValue]];
							NSString *extract2 = [dict[@"extract"] substringWithRange:NSMakeRange([dict[@"hiliteStart"] intValue],[dict[@"hiliteLength"] intValue])];
							NSString *extract3 = [dict[@"extract"] substringFromIndex:[dict[@"hiliteStart"] intValue] + [dict[@"hiliteLength"] intValue]];
							[resultFromJson appendFormat:@"<pre>%@<span>%@</span>%@</pre>",[HtmlTidyConfig escapeEntities:extract1], [HtmlTidyConfig escapeEntities:extract2], [HtmlTidyConfig escapeEntities:extract3]];
						}
						else {
							[resultFromJson appendFormat:@"<pre>%@</pre>",[HtmlTidyConfig escapeEntities:dict[@"extract"]]];
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
+ (instancetype)configWithTitle:(NSString *)aTitle intvalue:(int)aValue url:(NSString *)anUrl fieldname:(NSString*)aFieldname
{
    HtmlValidationConfig *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.validationUrl = anUrl;
	newConfig.validationFieldname = aFieldname;
    
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
	return [HtmlValidationConfig configForIntvalue:theencoding];
}

@end
