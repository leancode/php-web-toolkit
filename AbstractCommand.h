//
//  AbstractConfig.h
//  PhpPlugin
//
//  Created by Mario Fischer on 10.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Encoding.h"

@protocol AbstractConfig

	- (NSMutableArray*)getArgs;
	- (NSString*)getCmdline;

	- (void)setLineEnding: (NSString*)aLineEnding;
	- (NSString*)getLineEnding;
	- (void)setEncoding: (Encoding*)anEncoding;
	- (Encoding*)getEncoding;

@end

@interface AbstractCommand : NSObject <AbstractConfig>
{
	Encoding* encoding;
	NSString* lineEnding;
}
- (void)setLineEnding: (NSString*)aLineEnding;
- (NSString*)getLineEnding;
- (void)setEncoding: (Encoding*)anEncoding;
- (Encoding*)getEncoding;

@end
