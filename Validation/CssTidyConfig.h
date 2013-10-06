//
//  CssTidyConfig.h
//  PhpPlugin
//
//  Created by Mario Fischer on 09.01.10.
//  Copyright 2010 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractCommand.h"

@interface CssTidyConfig : NSObject<NSCoding>
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
+ (CssTidyConfig *)configForIndex:(int)theIdx;
+ (CssTidyConfig *)configForIntvalue:(int)theValue;

@end
