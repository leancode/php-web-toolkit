//
//  PreferenceController.h
//  SpotQuery
//
//  Created by Mario Fischer on 22.09.07.
//  Copyright 2007 Mario Fischer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const PrefThumbnailSize;
extern NSString* const PrefCheckForUpdates;
extern NSString* const PrefShowPreviewThumbnails;
extern NSString* const PrefShowInfoPanel;
extern NSString* const PrefLocationPaths;
extern NSString* const PrefColumnsShown;
extern NSString* const PrefSavedSearches;
extern NSString* const PrefFiletypes;

@interface PreferenceController : NSWindowController {
	
	NSMutableArray *filetypes;
	NSMutableArray *locations;
	
	IBOutlet NSPanel *prefPanel;

	IBOutlet NSArrayController *locationsArrayController;
}

- (NSArray*)filetypeDescriptions;
- (NSString*)utiForDescription:(NSString*)aDescription;
- (NSString*)descriptionForUti:(NSString*)anUti;

- (unsigned)thumbnailSize;
- (BOOL)showPreviewThumbnails;
- (BOOL)showInfoPanel;

- (IBAction)locationsAddPressed:(id)sender;
- (IBAction)savePressed: (id)sender;
- (IBAction)cancelPressed: (id)sender;

@property (readwrite, copy) NSMutableArray *filetypes;
@property (readwrite, copy) NSMutableArray *locations;

@end