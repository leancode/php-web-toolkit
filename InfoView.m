
//
//  InfoView.m
//  PhpPlugin
//
//  Created by mario on 10.03.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "InfoView.h"


@implementation InfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[self window] performClose:self];
}

@end
