
//
//  InfoView.m
//  PhpPlugin
//
//  Created by mario on 10.03.11.
//

#import "InfoView.h"


@implementation InfoView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[self.window performClose:self];
}

@end
