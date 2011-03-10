//
//  PreferenceController.m
//  SpotQuery
//
//  Created by Mario Fischer on 22.09.07.
//  Copyright 2007 Mario Fischer. All rights reserved.
//

#import "PreferenceController.h"

NSString* const PrefThumbnailSize = @"ThumbnailSize";
NSString* const PrefCheckForUpdates = @"SUCheckAtStartup";
NSString* const PrefShowPreviewThumbnails = @"ShowPreviewThumbnails";
NSString* const PrefShowInfoPanel = @"ShowInfoPanel";
NSString* const PrefLocationPaths = @"LocationPaths";
NSString* const PrefColumnsShown = @"ColumnsShown";
NSString* const PrefSavedSearches = @"SavedSearches";
NSString* const PrefFiletypes = @"Filetypes";

@implementation PreferenceController

# pragma mark -
# pragma mark Init and windowspecific

- (id)init 
{ 
    self = [super initWithWindowNibName:@"Preferences"]; 
	
	@try {
		filetypes = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PrefFiletypes]];
	}
	@catch (NSException *e) {
		NSLog(@"Error loading filetypes: %@", e);
		filetypes = [[NSMutableArray alloc] init];
	}	
	
	@try {
		locations = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PrefLocationPaths]];
	}
	@catch (NSException *e) {
		NSLog(@"Error loading locations: %@", e);
		locations = [[NSMutableArray alloc] init];
	}
	
    return self; 
}

# pragma mark -
# pragma mark Getters

- (NSArray*)filetypeDescriptions
{
	NSMutableArray* descriptions = [[NSMutableArray alloc] init];
	for (id ftype in filetypes) {
		if ([ftype description] != nil) {
			[descriptions addObject:[ftype description]];
		}
	}
	return [NSArray arrayWithArray:descriptions];
}

- (NSString*)utiForDescription:(NSString*)aDescription
{
	for (id ftype in filetypes) {
		if ([[ftype description] isEqualToString:aDescription]) {
			return [ftype uti];
		}
	}
	return @"";
}

- (NSString*)descriptionForUti:(NSString*)anUti
{
	for (id ftype in filetypes) {
		if ([[ftype uti] isEqualToString:anUti]) {
			return [ftype description];
		}
	}
	return @"";
}

- (unsigned)thumbnailSize
{
    return [[NSUserDefaults standardUserDefaults] integerForKey: PrefThumbnailSize]; 
}

- (BOOL)showPreviewThumbnails 
{ 
    return [[NSUserDefaults standardUserDefaults] boolForKey: PrefShowPreviewThumbnails]; 
} 

- (BOOL)showInfoPanel
{ 
    return [[NSUserDefaults standardUserDefaults] boolForKey: PrefShowInfoPanel]; 
} 

# pragma mark -
# pragma mark Actions

- (IBAction)locationsAddPressed:(id)sender
{
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setResolvesAliases:YES];
	[panel setTitle:NSLocalizedString(@"Choose a directory", @"Title for pref path chooser")];
	[panel setPrompt:NSLocalizedString(@"Choose…", @"Prompt for path chooser")];
	
	[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:prefPanel
					modalDelegate:self
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo:self];
}

- (void)openPanelDidEnd:(NSOpenPanel*)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[panel orderOut:self];
	if (returnCode != NSOKButton) {
		return;
	}
	
	NSArray* paths = [panel URLs];
	NSURL* url = [paths objectAtIndex: 0];
	NSString* new_description = [[url path] lastPathComponent];
	if (new_description != nil && url != nil) {
	}
}

- (IBAction)savePressed: (id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject:filetypes] forKey:PrefFiletypes];
	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject:locations] forKey:PrefLocationPaths];
	
	[self close];
}

- (IBAction)cancelPressed: (id)sender
{
	[self close];	
}
	 
@synthesize filetypes;
@synthesize locations;

@end