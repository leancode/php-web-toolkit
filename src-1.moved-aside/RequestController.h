//
//  RequestController.h
//  PhpPlugin
//
//  Created by mario on 11.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhpPlugin;

@interface RequestController : NSObject {
@private
		PhpPlugin *myPlugin;
		NSMutableString *myUrl;
		NSMutableData *receivedData;
}
- (void)setMyPlugin:(PhpPlugin*)myPluginInstance;

- (void)startRequest:(NSString*)myurl;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
