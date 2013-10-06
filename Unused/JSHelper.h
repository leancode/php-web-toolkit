//
//  JSHelper.h
//  PhpPlugin
//
//  Created by Mario Fischer on 24.02.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import <JavaScriptCore/JSBase.h>
#import <JavaScriptCore/JSContextRef.h>
#import <JavaScriptCore/JSStringRef.h>
#import <JavaScriptCore/JSStringRefCF.h>
#import <JavaScriptCore/JSValueRef.h>

@interface JSHelper : NSObject {

}
	+ (id) convertJSValueRef: (JSValueRef) jsValue context:(JSContextRef) ctx;
	+ (id) executeScript: (NSString*)jsScript;
@end
