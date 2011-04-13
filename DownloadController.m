//
//  DownloadController.m
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//  Copyright 2011 wysiwyg software design gmbh. All rights reserved.
//

#import "DownloadController.h"
#import "PhpPlugin.h"

NSString* const TmpUpdateFile = @"coda-plugin-update.zip";
NSString* const TmpUnpackedFile = @"PhpPlugin.codaplugin";
NSString* const DownloadUrl = @"http://www.chipwreck.de/downloads/php-codaplugin-current.zip";

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
	theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (theDownload)
	{		
		[[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUpdateFile] error:NULL];
		[[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUnpackedFile] error:NULL];
		
        [theDownload setDestination:[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUpdateFile] allowOverwrite:YES];

		[downloadPanel makeKeyAndOrderFront:self];
		[downloadWebButton setEnabled:NO];
		[responseLabel setStringValue:@"Download started."];
    }
	else {
		[self reportError:[NSString stringWithFormat:@"Could not start download. Perhaps no access to @%", [NSTemporaryDirectory() stringByAppendingPathComponent:TmpUpdateFile]]];
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
	else {
		[progressIndicator setIndeterminate:YES];
		[responseLabel setStringValue:[NSString stringWithFormat:@"%lld bytes received", bytesReceived]];
    }
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    [download release];
	[progressIndicator stopAnimation:self];
	[self reportError:[NSString stringWithFormat:@"Download failed: %@", [error localizedDescription]]];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    [download release];
	[progressIndicator stopAnimation:self];
	[responseLabel setStringValue:@"Finished."];
	[self extractAndInstall:self];	
}

- (IBAction)extractAndInstall:(id)sender
{
	@try {
		[responseLabel setStringValue:@"Unpacking..."];
		
		NSTask *unzipTask = [[NSTask alloc] init]; //if ([[NSWorkspace sharedWorkspace] openFile:TmpUpdateFile withApplication:@"Finder" andDeactivate:YES]) {
		[unzipTask setLaunchPath:@"/usr/bin/unzip"];
		[unzipTask setCurrentDirectoryPath:NSTemporaryDirectory()];
		[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", @"-q",[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUpdateFile], nil]];
		[unzipTask launch];
		[unzipTask waitUntilExit];
		
		[responseLabel setStringValue:@"Unpacking done."];
		
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUnpackedFile]])
		{
			if ([[NSWorkspace sharedWorkspace] openFile:[[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:TmpUnpackedFile]] path] withApplication:@"Coda"]) {
				[downloadPanel close];
			}
			else {
				[self reportError:[NSString stringWithFormat:@"Could not open %@ with Coda", [NSTemporaryDirectory() stringByAppendingPathComponent:TmpUnpackedFile]]];
			}
		}
		else {
			[self reportError:[NSString stringWithFormat:@"Could find unpacked file %@", [NSTemporaryDirectory() stringByAppendingPathComponent:TmpUnpackedFile]]];
		}
		
		[unzipTask release];
	}
	@catch (NSException *e) {
		[self reportError:[NSString stringWithFormat:@"Exception: %@", [e reason]]];
	}
}

- (IBAction)downloadWebsite:(id)sender
{
	[myPlugin downloadUpdateWeb];
	[downloadPanel close];
}

- (void)reportError:(NSString*)err
{
	[myPlugin doLog:err];
	[responseLabel setStringValue:[NSString stringWithFormat:@"Error!\n%@\n\nClick the button to download from the website", err]];
	[responseLabel setTextColor:[NSColor redColor]];
	
	[downloadWebButton setEnabled:YES];
}

- (void)dealloc
{
	[theDownload release];
    [super dealloc];
}

@end
