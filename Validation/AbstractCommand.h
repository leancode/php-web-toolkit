//
//  AbstractConfig.h
//  PhpPlugin
//
//  Created by Mario Fischer on 10.03.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CwEncoding.h"

@protocol AbstractConfig

	- (NSMutableArray*)getArgs;
	- (NSString*)getCmdline;

	- (void)setLineEnding: (NSString*)aLineEnding;
	- (NSString*)getLineEnding;
	- (void)setEncoding: (CwEncoding*)anEncoding;
	- (CwEncoding*)getEncoding;

@end

@interface AbstractCommand : NSObject <AbstractConfig>
{
	CwEncoding* encoding;
	NSString* lineEnding;
}
- (void)setLineEnding: (NSString*)aLineEnding;
- (NSString*)getLineEnding;
- (void)setEncoding: (CwEncoding*)anEncoding;
- (CwEncoding*)getEncoding;

@end
