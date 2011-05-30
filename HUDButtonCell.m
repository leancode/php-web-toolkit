//
//  HUDButton.m
//  PhpPlugin
//
//  Created by mario on 23.04.11.
//

#import "HUDButtonCell.h"

@implementation HUDButtonCell

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
	cellFrame.origin.x += 0.5f;
	cellFrame.size.width -= 3;	
	
	if ([self isHighlighted]) {
		cellFrame.origin.y += 1.0f;
		cellFrame.size.height -= 3.5f;
	}
	else {
		cellFrame.origin.y += 0.5f;
		cellFrame.size.height -= 3;
	}
	
	NSBezierPath *path = [[NSBezierPath alloc] init];
	[path appendBezierPathWithRect: cellFrame];

	// Background + Shadow
	
	NSGradient *mygrad;
	if ([self isEnabled]) {
		
		[NSGraphicsContext saveGraphicsState];
		{
			NSShadow *myshadow = [[NSShadow alloc] init];
			[myshadow setShadowColor: [NSColor blackColor]];
			[myshadow setShadowBlurRadius: 2];
			[myshadow setShadowOffset: NSMakeSize( 1, -2)];
			[[myshadow autorelease] set];
			
			[[NSColor colorWithDeviceWhite:0.1f alpha: 0.6f] set];
			[path setLineWidth: 1.0f];
			[path stroke];
		}
		[NSGraphicsContext restoreGraphicsState];
		
		if ([self isHighlighted]) {
			mygrad = [[[NSGradient alloc] initWithColorsAndLocations:
					   [NSColor colorWithDeviceWhite:0.75f alpha: 0.6f], (CGFloat)0,
					   [NSColor colorWithDeviceWhite:0.3f alpha: 0.6f], (CGFloat)1.0f, nil] autorelease];
		} else {
			mygrad = [[[NSGradient alloc] initWithColorsAndLocations:
					   [NSColor colorWithDeviceWhite:0.4f alpha: 0.6f], (CGFloat)0,
					   [NSColor colorWithDeviceWhite:0.25f alpha: 0.6f], (CGFloat)0.5f,
					   [NSColor colorWithDeviceWhite:0.2f alpha: 0.6f], (CGFloat)0.5f,
					   [NSColor colorWithDeviceWhite:0.1f alpha: 0.6f], (CGFloat)1.0f, nil] autorelease];
		}
	} else {
		mygrad = [[[NSGradient alloc] initWithColorsAndLocations:
				   [NSColor colorWithDeviceWhite:0.3f alpha: 0.6f], (CGFloat)0,
				   [NSColor colorWithDeviceWhite:0.1f alpha: 0.6f], (CGFloat)1.0f, nil] autorelease];
	}
	[mygrad drawInBezierPath: path angle: 90];
	
	// Border	
	[[NSColor colorWithDeviceWhite:0.6f alpha: 0.6f] set];
	[path setLineWidth: 1.0f];
	[path stroke];
	
	[path release];
	[self drawTitle: [self attributedTitle] withFrame: cellFrame inView: [self controlView]];
}

-(NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView 
{		
	NSMutableAttributedString *newTitle = [title mutableCopy];

	if ([newTitle size].height < 14.0f) {
		frame.origin.y += 1;
	}
	else {
		frame.origin.y -= 1;
	}

	frame.origin.x += 6;
	frame.size.width -= 10;
	
	[newTitle beginEditing];
	if ([self isEnabled]) {
		[newTitle addAttribute: NSForegroundColorAttributeName
						 value: [NSColor whiteColor]
						 range: NSMakeRange(0, [newTitle length])];
	} else {
		[newTitle addAttribute: NSForegroundColorAttributeName
						 value: [NSColor colorWithDeviceWhite:1.0 alpha: 0.2f]
						 range: NSMakeRange(0, [newTitle length])];
	}
	[newTitle endEditing];
	
	[super drawTitle: newTitle withFrame: frame inView: controlView];	
	[newTitle release];
	return frame;
}

- (void)dealloc
{
    [super dealloc];
}

@end
