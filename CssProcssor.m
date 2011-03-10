//
//  CssProcssor.m
//  PhpPlugin
//
//  Created by Mario Fischer on 16.10.10.
//  Copyright 2010 chipwreck.de. All rights reserved.
//
/*
Boolean values:
 
x blank_line_rules - Blank Line Between Rules  
x docblock - Improve Comments 
x selectors_on_same_line - Selectors of a Rule [On Separate Lines/Same Line]    
x safe - Fail-Safe Mode (boolean)
x grouping - Group (boolean) 
x tabbing - Columnize (boolean)
x indent_rules - Indent (boolean)

x braces - Set brace style - default, aligned_braces, pico, pico_extra, gnu, gnu_saver, banner, horstmann
x sort_declarations - Sorts Declarations. Only works with ‘fail-safe mode’ disabled.
x property_formatting - Properties of a Rule [ On Separate Lines if > 1 /  Separate Lines / Same Line ] - newline>1, newline, same_line
x sort_declarations - length, length_desc, abc, abc_desc 
x indent_size - default, 1, 2, 3, 4
x  alignment - left,right - Set selector alignment. Only works with ‘tabbing' (or 'columnize’) enabled.

! indent_type - tab,space 
 
Example Query: http://procssor.com/api?source=uri&css=http://graphics8.nytimes.com/css/0.1/screen/build/homepage/styles.css&indent_rules=1&indent_size=default
*/

#import "CssProcssor.h"

@implementation CssProcssor

@synthesize intvalue, title, cmdLineParam;

/* Predefined global list of configs */

+ (NSArray*)configArrayFormatting
{
    static NSArray *configsFormatting;
    if (!configsFormatting)
    {
		configsFormatting = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"New line (for > 1)" intvalue:0 cmdLine:@"property_formatting=newline>1"],
            [CssProcssor configWithTitle:@"New line (always)" intvalue:1 cmdLine:@"property_formatting=newline"],
			[CssProcssor configWithTitle:@"Same line" intvalue:2 cmdLine:@"property_formatting=same_line"],
		nil];
    }
    return configsFormatting;
}

+ (NSArray*)configArrayBraces
{
    static NSArray *configsBraces;
    if (!configsBraces)
    {
		configsBraces = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"Default" intvalue:0 cmdLine:@"braces=default"],
            [CssProcssor configWithTitle:@"Aligned Braces" intvalue:1 cmdLine:@"braces=aligned_braces"],
			[CssProcssor configWithTitle:@"Pico" intvalue:2 cmdLine:@"braces=pico"],
			[CssProcssor configWithTitle:@"Pico Extra" intvalue:3 cmdLine:@"braces=pico_extra"],
			[CssProcssor configWithTitle:@"Gnu" intvalue:4 cmdLine:@"braces=gnu"],
			[CssProcssor configWithTitle:@"Gnu Saver" intvalue:5 cmdLine:@"braces=gnu_saver"],
			[CssProcssor configWithTitle:@"Banner" intvalue:6 cmdLine:@"braces=banner"],
			[CssProcssor configWithTitle:@"Horstmann" intvalue:7 cmdLine:@"braces=horstmann"],
		nil];
    }
    return configsBraces;
}

+ (NSArray*)configArraySorting
{
    static NSArray *configsSorting;
    if (!configsSorting)
    {
		configsSorting = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"None" intvalue:0 cmdLine:@"sort_declarations=none"],
            [CssProcssor configWithTitle:@"ABC ascending" intvalue:1 cmdLine:@"sort_declarations=abc"],
			[CssProcssor configWithTitle:@"ABC descending" intvalue:2 cmdLine:@"sort_declarations=abc_desc"],
            [CssProcssor configWithTitle:@"Length ascending" intvalue:3 cmdLine:@"sort_declarations=length"],
			[CssProcssor configWithTitle:@"Length descending" intvalue:4 cmdLine:@"sort_declarations=length_desc"],
		nil];
    }
    return configsSorting;
}

+ (NSArray*)configArrayAlignment
{
    static NSArray *configsAlignment;
    if (!configsAlignment)
    {
		configsAlignment = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"Left" intvalue:0 cmdLine:@"alignment=left"],
            [CssProcssor configWithTitle:@"Right" intvalue:1 cmdLine:@"alignment=right"],
		nil];
    }
    return configsAlignment;
}

+ (NSArray*)configArrayIndentSize
{
    static NSArray *configsIndentSize;
    if (!configsIndentSize)
    {
		configsIndentSize = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"Default" intvalue:0 cmdLine:@"indent_size=default"],
			[CssProcssor configWithTitle:@"1" intvalue:1 cmdLine:@"indent_size=1"],
            [CssProcssor configWithTitle:@"2" intvalue:2 cmdLine:@"indent_size=2"],
			[CssProcssor configWithTitle:@"3" intvalue:3 cmdLine:@"indent_size=3"],
			[CssProcssor configWithTitle:@"4" intvalue:4 cmdLine:@"indent_size=4"],
		nil];
    }
    return configsIndentSize;
}

+ (NSArray*)configArrayIndentLevels
{
    static NSArray *configIndentLevels;
    if (!configIndentLevels)
    {
		configIndentLevels = [[NSArray alloc] initWithObjects:
			[CssProcssor configWithTitle:@"1 Level" intvalue:0 cmdLine:@"max_child_level=1"],
			[CssProcssor configWithTitle:@"2 Levels" intvalue:1 cmdLine:@"max_child_level=2"],
            [CssProcssor configWithTitle:@"3 Levels" intvalue:2 cmdLine:@"max_child_level=3"],
			[CssProcssor configWithTitle:@"4 Levels" intvalue:3 cmdLine:@"max_child_level=4"],
		nil];
    }
    return configIndentLevels;
}


+ (CssProcssor *)configForIntvalueFormatting:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArrayFormatting] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssProcssor *)configForIntvalueAlignment:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArrayAlignment] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssProcssor *)configForIntvalueBraces:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArrayBraces] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssProcssor *)configForIntvalueSorting:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArraySorting] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssProcssor *)configForIntvalueIndentSize:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArrayIndentSize] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

+ (CssProcssor *)configForIntvalueIndentLevels:(int)theValue
{
	NSEnumerator *configEnumerator = [[CssProcssor configArrayIndentLevels] objectEnumerator];
	CssProcssor * aconfig;
	while (aconfig = [configEnumerator nextObject])
	{
		if (theValue == [aconfig intvalue])
		{
			return aconfig;			
		}
	}
	return nil;
}

/* Convenience constructor */
+ (id)configWithTitle:(NSString *)aTitle intvalue:(int)aValue cmdLine:(NSString *)aCmdLine
{
    CssProcssor *newConfig = [[self alloc] init];
    newConfig.title = aTitle;
    newConfig.intvalue = aValue;
	newConfig.cmdLineParam = aCmdLine;
    
    return newConfig;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger: intvalue forKey:@"encoding"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	int theencoding = 0;
	theencoding = [decoder decodeIntegerForKey:@"encoding"];
	return [CssProcssor configForIntvalueFormatting:theencoding];
}

@end