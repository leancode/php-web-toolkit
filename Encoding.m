//
//  Encoding.m
//  PhpPlugin
//
//  Created by Mario Fischer on 06.11.09.
//  Copyright 2009 chipwreck.de. All rights reserved.
//

#import "Encoding.h"

@implementation Encoding

/*		NSJapaneseEUCStringEncoding = 3,
		NSNonLossyASCIIStringEncoding = 7,
		NSShiftJISStringEncoding = 8,
		NSISOLatin2StringEncoding = 9,
		NSWindowsCP1251StringEncoding = 11,    // Cyrillic; same as AdobeStandardCyrillic 
		NSWindowsCP1253StringEncoding = 13,    // Greek 
		NSWindowsCP1254StringEncoding = 14,    // Turkish 
		NSWindowsCP1250StringEncoding = 15,    // WinLatin2 
*/

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of encodings */
+ (NSArray*)encodingsArray
{
    static NSArray *encodings;
    if (!encodings)
    {
		encodings = [[NSArray alloc] initWithObjects:
			[Encoding encodingWithTitle:@"Always ask…" intvalue:0 cmdLine:@""],
			[Encoding encodingWithTitle:@"ASCII" intvalue:1 cmdLine:@"-ascii"],
            [Encoding encodingWithTitle:@"UTF-8" intvalue:4 cmdLine:@"-utf8"],
            [Encoding encodingWithTitle:@"ISO Latin 1" intvalue:5 cmdLine:@"-latin1"],
			[Encoding encodingWithTitle:@"UTF-16" intvalue:10 cmdLine:@"-utf16"], // NSUnicodeStringEncoding = 10, NSUTF16StringEncoding
            [Encoding encodingWithTitle:@"Windows CP1252" intvalue:12 cmdLine:@"-win1252"],
            [Encoding encodingWithTitle:@"MacRoman" intvalue:30 cmdLine:@"-mac"], nil];
    }
    return encodings;
}

/* Retrieve encoding with given encoding from 'encodingsArray' (see NSCoding methods) */
+ (Encoding *)encodingForIntvalue:(int)theValue
{
	NSEnumerator *encodingEnumerator = [[Encoding encodingsArray] objectEnumerator];
	Encoding *anencoding;
	while ((anencoding = [encodingEnumerator nextObject]))
	{
		if (theValue == [anencoding intvalue])
		{
			return anencoding;			
		}
	}
	
	return nil;
}

+ (Encoding *)encodingForIndex:(int)theIdx
{
	return [[Encoding encodingsArray] objectAtIndex:theIdx];
}

/* Convenience constructor */
+ (id)encodingWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    Encoding *newEncoding = [[self alloc] init];
    newEncoding.title = aTitle;
    newEncoding.intvalue = aValue;
	newEncoding.cmdLineParam = aCmdLine;
    
    return [newEncoding autorelease];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger: intvalue forKey:@"encoding"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	int theencoding = 0;
	theencoding = [decoder decodeIntegerForKey:@"encoding"];
	return [[Encoding encodingForIntvalue:theencoding] retain];
}

@end