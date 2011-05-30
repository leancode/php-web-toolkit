//
//  ValidationController.h
//  PhpPlugin
//
//  Created by mario on 14.04.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ValidationController : NSObject {

    
}

-(NSStringEncoding)encoding;
-(NSString*)input;
-(NSMutableString *)filterTextInput:(NSString *)textInput with:(NSString *)launchPath options:(NSMutableArray *)cmdlineOptions encoding:(NSStringEncoding)anEncoding useStdout:(BOOL)useout;

@end
