//
//  DownloadController.m
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//

#import "DownloadController.h"
#import "PhpPlugin.h"

NSString* const TmpUnpackedFile = @"PhpPlugin.codaplugin";

@implementation DownloadController

@synthesize downloadPath, downloadUrl, downloadFilename, theDownload, downloadResponse;

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

- (void)startDownloadingURL:(NSString*)url
{
	if (url == nil) {
		[self reportError:@"No download URL given"];
		return;
	}
	[self setDownloadUrl:url];
	
	// Create destination dir	
	NSString *nowTimestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
	[self setDownloadPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[@"coda-plugin-update-" stringByAppendingString:nowTimestamp]]];
	NSError *myerr;
	if (![[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:NO attributes:nil error:&myerr]) {
		[self reportError:[NSString stringWithFormat:@"Could not create temporary path: %@, %@", downloadPath, [myerr localizedDescription]]];
		return;
	}
	
	// Create request
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]
												cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData //NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0];
	theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (theDownload)
	{
		[downloadPanel makeKeyAndOrderFront:self];
		[downloadWebButton setEnabled:NO];
		[responseLabel setStringValue:@"Download initialized."];
    }
	else {
		[self reportError:[NSString stringWithFormat:@"Could not start download from %@. Perhaps no access to @%", downloadUrl, downloadPath]];
    }
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
	[self setDownloadFilename:filename];
    [theDownload setDestination:[downloadPath stringByAppendingPathComponent:downloadFilename] allowOverwrite:YES];
	[myPlugin doLog:[NSString stringWithFormat:@"decideDestinationWithSuggestedFilename %@, final dest is: %@", filename, [downloadPath stringByAppendingPathComponent:downloadFilename]]];
}

-(void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
	[responseLabel setStringValue:@"Download started."];
	[progressIndicator startAnimation:self];
	[myPlugin doLog:[NSString stringWithFormat:@"didCreateDestination %@, final dest is: %@", path, [downloadPath stringByAppendingPathComponent:downloadFilename]]];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    bytesReceived = 0;
    [self setDownloadResponse:response];
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
		
		NSTask *unzipTask = [[NSTask alloc] init];
		[unzipTask setLaunchPath:@"/usr/bin/unzip"];
		[unzipTask setCurrentDirectoryPath:downloadPath];
		[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", @"-q",[downloadPath stringByAppendingPathComponent:downloadFilename], nil]];
		[unzipTask launch];
		[unzipTask waitUntilExit];
		
		[responseLabel setStringValue:@"Unpacking done."];
		
		NSString *unpackedFolder = [downloadPath stringByAppendingPathComponent:[downloadFilename stringByDeletingPathExtension]];
		NSString *unpackedBundle = [unpackedFolder stringByAppendingPathComponent:TmpUnpackedFile];
		
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:unpackedBundle])
		{
			if ([[NSWorkspace sharedWorkspace] openFile:[[NSURL fileURLWithPath:unpackedBundle] path] withApplication:@"Coda"]) {
				[downloadPanel close];
			}
			else {
				[self reportError:[NSString stringWithFormat:@"Could not open %@ with Coda", unpackedBundle]];
			}
		}
		else {
			[self reportError:[NSString stringWithFormat:@"Could find unpacked file %@", unpackedBundle]];
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
	[downloadPanel makeKeyAndOrderFront:self];
	[myPlugin doLog:err];
	[responseLabel setStringValue:[NSString stringWithFormat:@"Error!\n%@\n\nClick the button to download from the website", err]];
	[responseLabel setTextColor:[NSColor redColor]];
	
	[downloadWebButton setEnabled:YES];
}

- (void)dealloc
{
    [super dealloc];
}

@end
