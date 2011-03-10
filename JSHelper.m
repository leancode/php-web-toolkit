//
//  JSHelper.m
//  PhpPlugin
//
//  Created by Mario Fischer on 24.02.11.
//  Copyright 2011 chipwreck.de. All rights reserved.
//

#import "JSHelper.h"


@implementation JSHelper


+ (id) executeScript: (NSString*)jsScript
{
	JSContextRef ctx = JSGlobalContextCreate(NULL);
		//    const char* const script = "function myfunc(i){return i;}/*var i = 10;/*return '123';*/ myfunc('hallo');";
    JSStringRef scriptRef = JSStringCreateWithUTF8CString([jsScript UTF8String]);
    JSValueRef exception = 0;
    JSValueRef resultRef = 0;

    resultRef = JSEvaluateScript(ctx, scriptRef, 0, 0, 0, &exception);
	return [JSHelper convertJSValueRef:resultRef context: ctx];
}


+ (id) convertJSValueRef: (JSValueRef) jsValue context:(JSContextRef) ctx
{
	switch (JSValueGetType(ctx,jsValue)) {
		case kJSTypeUndefined:
			return nil;
		case kJSTypeNull:
			return [NSNull null];
		case kJSTypeBoolean:
			if (JSValueToBoolean(ctx, jsValue)) {
				return [NSNumber numberWithBool:YES];
			} else {
				return [NSNumber numberWithBool:NO];
			}
		case kJSTypeNumber:
			return [NSNumber numberWithDouble:JSValueToNumber(ctx,jsValue, NULL)];

		case kJSTypeString: {
			JSStringRef resultStringJS = JSValueToStringCopy(ctx, jsValue, NULL);
			CFStringRef resultString = JSStringCopyCFString(kCFAllocatorDefault, resultStringJS);
			JSStringRelease(resultStringJS);
			return [(NSString *)resultString autorelease];
		}
		case kJSTypeObject: {
			if (!JSObjectIsFunction(ctx, (JSObjectRef)jsValue) && 
				!JSObjectIsConstructor(ctx, (JSObjectRef)jsValue)) {
				static JSStringRef lengthStr = nil;
				if (!lengthStr)
					lengthStr = JSStringCreateWithCFString((CFStringRef)@"length");
				if (JSObjectHasProperty(ctx, (JSObjectRef)jsValue, lengthStr)) {
					static JSStringRef arrayStr = nil;
					if (!arrayStr)
						arrayStr = JSStringCreateWithCFString((CFStringRef)@"Array");
					JSValueRef arrayConstructor = JSObjectGetProperty(ctx, JSContextGetGlobalObject(ctx), arrayStr, NULL);
					if (JSValueIsObject(ctx, arrayConstructor) &&
						JSObjectIsConstructor(ctx, (JSObjectRef)arrayConstructor)) {
						if (JSValueIsInstanceOfConstructor(ctx, (JSObjectRef)jsValue, (JSObjectRef)arrayConstructor, NULL)) {
								// finally!  We know that it is an array!
							return nil; // (arr) [[[JSKitArrayWrapper alloc] initWithObject: (JSObjectRef) jsValue context: ctx] autorelease];
						}
					}
				}
			}
			return nil; // (obj) [JSKitObject objectWithObject: (JSObjectRef)jsValue context: ctx];
		}
	}
    return nil;
}


@end
