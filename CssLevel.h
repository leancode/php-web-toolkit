//
//  CssLevel.h
//  PhpPlugin
//
//  Created by Mario Fischer on 08.01.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CssLevel : NSObject<NSCoding>
{
@public
    int intvalue;
    NSString *title;
	NSString *cmdLineParam;
}

@property int intvalue;
@property (copy) NSString *title;
@property (copy) NSString *cmdLineParam;

+ (NSArray *)configArray;
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine;
+ (CssLevel *)configForIndex:(int)theIdx;
+ (CssLevel *)configForIntvalue:(int)theValue;

@end
