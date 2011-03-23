//
//  Parser.h
//  PhpPlugin
//
//  Created by mario on 23.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResultParser <NSObject>
+ (NSMutableString*)parse:(NSMutableString*)input;
@end
