//
//  CssProcssor.h
//  PhpPlugin
//
//  Created by Mario Fischer on 16.10.10.
//  Copyright 2010 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CssProcssor : NSObject<NSCoding>
{
@public
    int intvalue;
    NSString *title;
	NSString *cmdLineParam;
}

@property int intvalue;
@property (copy) NSString *title;
@property (copy) NSString *cmdLineParam;


+ (NSArray*)configArrayBraces;
+ (NSArray*)configArrayFormatting;
+ (NSArray*)configArraySorting;
+ (NSArray*)configArrayAlignment;
+ (NSArray*)configArrayIndentSize;
+ (NSArray*)configArrayIndentLevels;
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine;
+ (CssProcssor *)configForIntvalueFormatting:(int)theValue;
+ (CssProcssor *)configForIntvalueBraces:(int)theValue;
+ (CssProcssor *)configForIntvalueSorting:(int)theValue;
+ (CssProcssor *)configForIntvalueAlignment:(int)theValue;
+ (CssProcssor *)configForIntvalueIndentSize:(int)theValue;
+ (CssProcssor *)configForIntvalueIndentLevels:(int)theValue;

@end
