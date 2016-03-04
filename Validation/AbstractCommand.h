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

	@property (NS_NONATOMIC_IOSONLY, getter=getArgs, readonly, copy) NSMutableArray *args;
	@property (NS_NONATOMIC_IOSONLY, getter=getCmdline, readonly, copy) NSString *cmdline;


	@property (NS_NONATOMIC_IOSONLY, getter=getLineEnding, copy) NSString *lineEnding;

	@property (NS_NONATOMIC_IOSONLY, getter=getEncoding, strong) CwEncoding *encoding;

@end

@interface AbstractCommand : NSObject <AbstractConfig>
{
	CwEncoding* encoding;
	NSString* lineEnding;
}
@property (NS_NONATOMIC_IOSONLY, getter=getLineEnding, copy) NSString *lineEnding;
@property (NS_NONATOMIC_IOSONLY, getter=getEncoding, strong) CwEncoding *encoding;

@end
