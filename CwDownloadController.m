//
//  CwDownloadController.m
//  PhpPlugin
//
//  Created by mario on 13.04.11.
//

#import "CwDownloadController.h"
#import "CwPreferenceController.h"
#import "CwPhpPlugin.h"

NSString* const TmpUnpackedFile = @"PhpPlugin.codaplugin";

@implementation CwDownloadController

@synthesize downloadPath, downloadUrl, downloadFilename, theDownload, downloadResponse;

- (id)init
{
	self = [super init];
	if (self != nil) {
		[NSBundle loadNibNamed:@"DownloadPanel" owner:self];
	}
    return self;
}

- (void)setMyPlugin:(CwPhpPlugin *)myPluginInstance
{
	myPlugin = myPluginInstance;
}

- (void)showPanelWithUrl:(NSString*)url
{
	if (url == nil) {
		[self reportError:@"No download URL given" additional:@""];
		return;
	}
	[self setDownloadUrl:url];
	
	[downloadWebButton setEnabled:NO];
	[downloadWebButton setHidden:YES];
	[updateButton setEnabled:YES];
	[updateButton setKeyEquivalent:@"\r"];
	[progressIndicator setDoubleValue:0.0];
	[responseLabel setStringValue:@"Click \"Install Update\" to start."];
	
	[downloadPanel makeKeyAndOrderFront:self];
}

- (IBAction)closePanel:(id)sender
{
	@try {
		
		if (theDownload != nil) {
			[theDownload cancel];
		}
	}
	@catch (NSException *e) {
		[self reportError:[NSString stringWithFormat:@"Exception: %@", [e reason]] additional:[e name]];
	}
	[downloadPanel close];
}

- (IBAction)startDownload:(id)sender
{
	// Create destination dir	
	NSString *nowTimestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
	[self setDownloadPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[@"coda-plugin-update-" stringByAppendingString:nowTimestamp]]];
	
	NSError *myerr;
	if (![[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:NO attributes:nil error:&myerr]) {
		[self reportError:@"Could not create temporary path" additional:[NSString stringWithFormat:@"%@\n%@", downloadPath, [myerr localizedDescription]]];
		return;
	}
	
	// Create request
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]
												cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData //NSURLRequestUseProtocolCachePolicy
											timeoutInterval:PrefTimeoutNS];
	theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
	if (theDownload) {
		[responseLabel setStringValue:@"Download initialized."];
		[updateButton setEnabled:NO];
    }
	else {
		[self reportError:[NSString stringWithFormat:@"Error: Could not start download from %@", downloadUrl] additional:downloadPath];
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
		double percentComplete = (90.0 * bytesReceived / expectedLength);
		unsigned percentInt = (int)(90.0 * bytesReceived / expectedLength);
		[progressIndicator setIndeterminate:NO];
		[progressIndicator setDoubleValue:percentComplete];		
		[responseLabel setStringValue:[NSString stringWithFormat:@"Downloading: %u%% done", percentInt]];
    } 
	else {
		[progressIndicator setIndeterminate:YES];
		[responseLabel setStringValue:[NSString stringWithFormat:@"Downloading: %lld bytes received", bytesReceived]];
    }
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    [download release];
	[progressIndicator stopAnimation:self];
	[self reportError:@"Download failed." additional:[error localizedDescription]];
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
		[progressIndicator setIndeterminate:NO];
		[progressIndicator setDoubleValue:91.0];
		
		NSTask *unzipTask = [[NSTask alloc] init];
		[unzipTask setLaunchPath:@"/usr/bin/unzip"];
		[unzipTask setCurrentDirectoryPath:downloadPath];
		[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", @"-q",[downloadPath stringByAppendingPathComponent:downloadFilename], nil]];
		[unzipTask launch];
		[unzipTask waitUntilExit];
		
		[progressIndicator setDoubleValue:100.0];
		[responseLabel setStringValue:@"Unpacking done."];
		
		NSString *unpackedFolder = [downloadPath stringByAppendingPathComponent:[downloadFilename stringByDeletingPathExtension]];
		NSString *unpackedBundle = [unpackedFolder stringByAppendingPathComponent:TmpUnpackedFile];
		NSString *appName;
		if ([myPlugin isCoda2]) {
			 appName = @"Coda 2";
		}
		else {
			appName = @"Coda"; 
		}
				
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:unpackedBundle]) {
			if ([[NSWorkspace sharedWorkspace] openFile:[[NSURL fileURLWithPath:unpackedBundle] path] withApplication:appName]) {
				[downloadPanel close]; // success!
			}
			else {
				[self reportError:@"Could not open bundle!" additional:unpackedBundle];
			}
		}
		else {
			[self reportError:@"Could not find unpacked file!" additional:unpackedBundle];
		}
		
		[unzipTask release];
	}
	@catch (NSException *e) {
		[self reportError:[NSString stringWithFormat:@"Exception: %@", [e reason]] additional:[e name]];
	}
}

- (IBAction)downloadWebsite:(id)sender
{
	[myPlugin downloadUpdateWeb];
	[downloadPanel close];
}

- (void)reportError:(NSString*)err additional:(NSString*)additional
{
	[downloadPanel makeKeyAndOrderFront:self];
	[myPlugin doLog:[err stringByAppendingFormat:@"\nadditional: %@", additional]];
	[responseLabel setStringValue:[NSString stringWithFormat:@"%@", err]];
	[responseLabel setTextColor:[NSColor redColor]];
	
	[progressIndicator setDoubleValue:0.0];
	[updateButton setEnabled:NO];
	[downloadWebButton setKeyEquivalent:@"\r"];
	[downloadWebButton setEnabled:YES];
	[downloadWebButton setHidden:NO];
}

- (void)dealloc
{
    [super dealloc];
}

@end
