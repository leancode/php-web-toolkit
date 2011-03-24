//
//  HtmlValidationConfig.h
//  PhpPlugin
//
//  Created by Mario Fischer on 09.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HtmlValidationConfig : NSObject<NSCoding>
{
@public
    int intvalue;
    NSString *title;
	NSString *validationUrl;
	NSString *validationFieldname;
}

@property int intvalue;
@property (copy) NSString *title;
@property (copy) NSString *validationUrl;
@property (copy) NSString *validationFieldname;

+ (NSArray *)configArray;
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue url:(NSString *)anUrl fieldname:(NSString*)aFieldname;
+ (NSMutableString*)parseValidatorNuOutput:(NSMutableDictionary*)jsonResult;
+ (HtmlValidationConfig *)configForIndex:(int)theIdx;
+ (HtmlValidationConfig *)configForUrl:(NSString*)theUrl;
+ (HtmlValidationConfig *)configForIntvalue:(int)theValue;

@end
