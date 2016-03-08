//
//  PhpTidyConfig.h
//  PhpPlugin
//
//  Created by Mario Fischer on 24.01.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PhpTidyConfig : NSObject<NSCoding>
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
+ (instancetype)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine;
+ (PhpTidyConfig *)configForIndex:(int)theIdx;
+ (PhpTidyConfig *)configForIntvalue:(int)theValue;


@end
