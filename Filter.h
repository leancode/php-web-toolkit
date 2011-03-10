//
//  Filter.h
//  PhpPlugin
//
//  Created by Mario Fischer on 30.12.08.
//  Copyright 2008 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Filter : NSObject {
@private
	NSString *title;
}
- (NSString *)title;

@property(readonly, assign) NSString* title;

@end
