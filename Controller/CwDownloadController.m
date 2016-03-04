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

@synthesize downloadPath, downloadUrl, downloadFilename, theDownload, downloadResponse, tlo;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		NSString *nibName = @"DownloadPanel";
		if([[NSBundle mainBundle] respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]){
			NSArray * t = nil;
			[[NSBundle mainBundle] loadNibNamed:nibName owner:self topLevelObjects:&t];
			tlo = t;
		} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			[NSBundle loadNibNamed:nibName owner:self];
#pragma clang diagnostic pop
		}
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
	self.downloadUrl = url;
	
	[downloadWebButton setEnabled:NO];
	[downloadWebButton setHidden:YES];
	[updateButton setEnabled:YES];
	updateButton.keyEquivalent = @"\r";
	progressIndicator.doubleValue = 0.0;
	responseLabel.stringValue = @"Click \"Install Update\" to start.";
	
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
		[self reportError:[NSString stringWithFormat:@"Exception: %@", e.reason] additional:e.name];
	}
	[downloadPanel close];
}

- (IBAction)startDownload:(id)sender
{
	// Create destination dir	
	NSString *nowTimestamp = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
	self.downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"coda-plugin-update-" stringByAppendingString:nowTimestamp]];
	
	NSError *myerr;
	if (![[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:NO attributes:nil error:&myerr]) {
		[self reportError:@"Could not create temporary path" additional:[NSString stringWithFormat:@"%@\n%@", downloadPath, myerr.localizedDescription]];
		return;
	}
	
	// Create request
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]
												cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData //NSURLRequestUseProtocolCachePolicy
											timeoutInterval:PrefTimeoutNS];
	theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
	if (theDownload) {
		responseLabel.stringValue = @"Download initialized.";
		[updateButton setEnabled:NO];
    }
	else {
		[self reportError:[NSString stringWithFormat:@"Error: Could not start download from %@", downloadUrl] additional:downloadPath];
    }
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
	self.downloadFilename = filename;
    [theDownload setDestination:[downloadPath stringByAppendingPathComponent:downloadFilename] allowOverwrite:YES];
	[myPlugin doLog:[NSString stringWithFormat:@"decideDestinationWithSuggestedFilename %@, final dest is: %@", filename, [downloadPath stringByAppendingPathComponent:downloadFilename]]];
}

-(void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
	responseLabel.stringValue = @"Download started.";
	[progressIndicator startAnimation:self];
	[myPlugin doLog:[NSString stringWithFormat:@"didCreateDestination %@, final dest is: %@", path, [downloadPath stringByAppendingPathComponent:downloadFilename]]];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    bytesReceived = 0;
    self.downloadResponse = response;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length;
{
	int64_t expectedLength = downloadResponse.expectedContentLength;
    bytesReceived += length;
	
    if (expectedLength != NSURLResponseUnknownLength)
	{
		double percentComplete = (90.0 * bytesReceived / expectedLength);
		unsigned percentInt = (int)(90.0 * bytesReceived / expectedLength);
		[progressIndicator setIndeterminate:NO];
		progressIndicator.doubleValue = percentComplete;		
		responseLabel.stringValue = [NSString stringWithFormat:@"Downloading: %u%% done", percentInt];
    } 
	else {
		[progressIndicator setIndeterminate:YES];
		responseLabel.stringValue = [NSString stringWithFormat:@"Downloading: %lld bytes received", bytesReceived];
    }
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	[progressIndicator stopAnimation:self];
	[self reportError:@"Download failed." additional:error.localizedDescription];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	[progressIndicator stopAnimation:self];
	responseLabel.stringValue = @"Finished.";
	[self extractAndInstall:self];	
}

- (IBAction)extractAndInstall:(id)sender
{
	@try {
		responseLabel.stringValue = @"Unpacking...";
		[progressIndicator setIndeterminate:NO];
		progressIndicator.doubleValue = 91.0;
		
		NSTask *unzipTask = [[NSTask alloc] init];
		unzipTask.launchPath = @"/usr/bin/unzip";
		unzipTask.currentDirectoryPath = downloadPath;
		unzipTask.arguments = @[@"-o", @"-q",[downloadPath stringByAppendingPathComponent:downloadFilename]];
		[unzipTask launch];
		[unzipTask waitUntilExit];
		
		progressIndicator.doubleValue = 100.0;
		responseLabel.stringValue = @"Unpacking done.";
		
		NSString *unpackedFolder = [downloadPath stringByAppendingPathComponent:downloadFilename.stringByDeletingPathExtension];
		NSString *unpackedBundle = [unpackedFolder stringByAppendingPathComponent:TmpUnpackedFile];
		NSString *appName;
		if ([myPlugin isCoda2]) {
			 appName = @"Coda 2";
		}
		else {
			appName = @"Coda"; 
		}
				
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:unpackedBundle]) {
			if ([[NSWorkspace sharedWorkspace] openFile:[NSURL fileURLWithPath:unpackedBundle].path withApplication:appName]) {
				[downloadPanel close]; // success!
			}
			else {
				[self reportError:@"Could not open bundle!" additional:unpackedBundle];
			}
		}
		else {
			[self reportError:@"Could not find unpacked file!" additional:unpackedBundle];
		}
		
	}
	@catch (NSException *e) {
		[self reportError:[NSString stringWithFormat:@"Exception: %@", e.reason] additional:e.name];
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
	responseLabel.stringValue = [NSString stringWithFormat:@"%@", err];
	responseLabel.textColor = [NSColor redColor];
	
	progressIndicator.doubleValue = 0.0;
	[updateButton setEnabled:NO];
	downloadWebButton.keyEquivalent = @"\r";
	[downloadWebButton setEnabled:YES];
	[downloadWebButton setHidden:NO];
}

- (void)dealloc{
	tlo = nil;
}

@end
