//
//  Uploader.h
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PhpPlugin;

@interface RequestController : NSObject
{
	PhpPlugin *myPlugin;
	
	NSURL *serverURL;
	NSDictionary *fields;
	
	NSData *contents;
	NSString *filename;
	NSString *mimetype;
	NSString *uploadfield;
	
	id delegate;
	SEL doneSelector;
	SEL errorSelector;
	
	NSMutableString *serverReply;
	NSMutableString *errorReply;	
	BOOL uploadDidSucceed;
}

- (id)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
         delegate: (id)aDelegate
     doneSelector: (SEL)aDoneSelector
    errorSelector: (SEL)anErrorSelector;

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance;

- (NSString *)serverReply;
- (NSString *)errorReply;

@end
