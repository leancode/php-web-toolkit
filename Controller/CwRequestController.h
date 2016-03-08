//
//  Uploader.h
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//

#import <Foundation/Foundation.h>
@class CwPhpPlugin;
@protocol CwPhpPluginDelegate;

@interface CwRequestController : NSObject
{
	NSURL *serverURL;
	NSDictionary *fields;
	
	NSData *contents;
	NSString *filename;
	NSString *mimetype;
	NSString *uploadfield;
	
	id<CwPhpPluginDelegate> delegate;
	
	NSMutableString *serverReply;
	NSMutableString *errorReply;	
	BOOL uploadDidSucceed;
}

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithURL: (NSURL *)aServerURL
         contents: (NSData *)aData
		   fields: (NSDictionary *)aFields
	  uploadfield: (NSString *)anUploadfield
		 filename: (NSString *)aFilename
		 mimetype: (NSString *)aMimetype
         delegate: (id<CwPhpPluginDelegate>)aDelegate NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL doUpload;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *serverReply;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *errorReply;

@end
