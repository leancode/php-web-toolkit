//
//  Encoding.h
//  PhpPlugin
//
//  Created by Mario Fischer on 06.11.09.
//  Copyright 2009 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Encoding : NSObject <NSCoding>
{
@public
    int intvalue;
    NSString *title;
	NSString *cmdLineParam;
}

@property int intvalue;
@property (copy) NSString *title;
@property (copy) NSString *cmdLineParam;

+ (NSArray *)encodingsArray;
+ (id)encodingWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine;
+ (Encoding *)encodingForIndex:(int)theIdx;
+ (Encoding *)encodingForIntvalue:(int)theValue;

@end
