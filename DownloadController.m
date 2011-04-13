//
//  DownloadController.m
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "DownloadController.h"
#import "PhpPlugin.h"

NSString* const TmpUpdateFile = @"/tmp/coda-plugin-update.zip";
NSString* const TmpUnpackedFile = @"/tmp/PhpPlugin.codaplugin";
NSString* const DownloadUrl = @"http://www.chipwreck.de/downloads/php-codaplugi-current.zip";

@implementation DownloadController

- (id)init
{
	self = [super init];
	if (self != nil) {
		[NSBundle loadNibNamed:@"DownloadPanel" owner:self];
	}
    return self;
}

- (void)setMyPlugin:(PhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (void)startDownloadingURL:sender
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:DownloadUrl]
												cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData //NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0];
	NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest
																delegate:self];
    if (theDownload) {
        [theDownload setDestination:TmpUpdateFile allowOverwrite:YES];
		[[NSFileManager defaultManager] removeItemAtPath:TmpUnpackedFile error:NULL];
		[downloadPanel orderFront:self];
		[responseLabel setStringValue:@""];
    } else {
		[responseLabel setStringValue:@"Could not start download (no access to /tmp/ ?)"];
    }
}

- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse
{
    [aDownloadResponse retain];
    [downloadResponse release];
    downloadResponse = aDownloadResponse;
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    bytesReceived = 0;
    [self setDownloadResponse:response];
	[progressIndicator startAnimation:self];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length;
{
	int64_t expectedLength = [downloadResponse expectedContentLength];
    bytesReceived += length;
	
    if (expectedLength != NSURLResponseUnknownLength) 
	{
		double percentComplete = (bytesReceived * 100.0 / expectedLength);
		unsigned percentInt = (int)(bytesReceived * 100.0 / expectedLength);
		[progressIndicator setDoubleValue:percentComplete];
		[responseLabel setStringValue:[NSString stringWithFormat:@"%u%% done", percentInt]];
    } 
	else 
	{
		[progressIndicator setIndeterminate:YES];
		[responseLabel setStringValue:[NSString stringWithFormat:@"%lld bytes received", bytesReceived]];
    }
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    [download release];
	[progressIndicator stopAnimation:self];
	[responseLabel setStringValue:[error localizedDescription]];
	[myPlugin doLog:[NSString stringWithFormat:@"Download failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey: NSErrorFailingURLStringKey]]]; // 10.6: NSURLErrorFailingURLStringErrorKey
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    [download release];
	[progressIndicator stopAnimation:self];
	[responseLabel setStringValue:@"Finished."];
	[self doneButtonPushed:self];	
}

- (IBAction)doneButtonPushed:(id)sender
{
	@try {
		[responseLabel setStringValue:@"Unpacking..."];
		
		NSTask *unzipTask = [[NSTask alloc] init]; //if ([[NSWorkspace sharedWorkspace] openFile:TmpUpdateFile withApplication:@"Finder" andDeactivate:YES]) {
		[unzipTask setLaunchPath:@"/usr/bin/unzip"];
		[unzipTask setCurrentDirectoryPath:@"/tmp/"];
		[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", TmpUpdateFile, nil]];
		[unzipTask launch];
		[unzipTask waitUntilExit];
		
		[responseLabel setStringValue:@"Unpacking done."];
		
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:TmpUnpackedFile]) {
			if ([[NSWorkspace sharedWorkspace] openFile:[[NSURL fileURLWithPath:TmpUnpackedFile] path] withApplication:@"Coda"]) {
				[downloadPanel close];
			}
			else {
				[responseLabel setStringValue:[NSString stringWithFormat:@"Could not open %@ with Coda", TmpUnpackedFile]];
				[myPlugin doLog:[NSString stringWithFormat:@"Could not open %@ with Coda", TmpUnpackedFile]];
			}
		}
		else {
			[responseLabel setStringValue:[NSString stringWithFormat:@"Could not find unpacked %@", TmpUnpackedFile]];
			[myPlugin doLog:[NSString stringWithFormat:@"Could not find unpacked file %@", TmpUnpackedFile]];
		}
		
		[unzipTask release];
	}
	@catch (NSException *e) {
		[myPlugin doLog:[NSString stringWithFormat:@"Exception in doneButtonPushed: %@", 
						 [[[e name] stringByAppendingString:NSLocalizedString(@"\n\nReason:\n",@"") ] stringByAppendingString:[e reason]]
		]];
		[responseLabel setStringValue:[NSString stringWithFormat:@"Exception:", [e name]]];
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end
