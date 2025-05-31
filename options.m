#include <Foundation/Foundation.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/select.h>

#import "options.h"
#import "nscolor+hex.h"
#import "config.h"

@implementation Options

- (NSColor *)fgColor {
    if (_fgColorHex == nil || [_fgColorHex isEqual:@""]) {
        return [NSColor fromHexString:@COLOR_FG];
    }

    return [NSColor fromHexString:_fgColorHex];
}

- (NSColor *)bgColor {
    if (_bgColorHex  == nil || [_bgColorHex isEqual:@""]) {
        return [NSColor fromHexString:@COLOR_BG];
    }

    return [NSColor fromHexString:_bgColorHex];
}
- (NSColor *)selectedFgColor {
    if (_selectedFgColorHex == nil || [_selectedFgColorHex isEqual:@""]) {
        return [NSColor fromHexString:@COLOR_SEL_FG];
    }

    return [NSColor fromHexString:_selectedFgColorHex];
}
- (NSColor *)selectedBgColor {
    if (_selectedBgColorHex == nil || [_selectedBgColorHex isEqual:@""]) {
        return [NSColor fromHexString:@COLOR_SEL_BG];
    }

    return [NSColor fromHexString:_selectedBgColorHex];
}

- (NSFont *)font {
    NSString *f = _fontString;
    if (f == nil || [f isEqual:@""]) {
        f = @FONT;
    }

    NSArray *parts = [f componentsSeparatedByString:@":"];
    NSString *fontName;
    CGFloat fontSize;

    if ([parts count] > 0) {
        fontName = [parts objectAtIndex:0];
    }

    for (NSUInteger i = 1; i < [parts count]; i++) {
        NSString *part = [parts objectAtIndex:i];
        NSArray *partPieces = [part componentsSeparatedByString:@"="];
        if ([partPieces count] == 2 && [[partPieces objectAtIndex:0] isEqualToString:@"size"]) {
            fontSize = [[partPieces objectAtIndex:1] floatValue];
        }
    }

    if (fontSize < 1.0) {
        fontSize = 10;
    }

    NSFont *font;
    if (fontName == nil || [fontName isEqual:@""]) {
        font = [NSFont systemFontOfSize:fontSize];
    } else if ([fontName isEqual:@"monospace"]) {
        font = [NSFont monospacedSystemFontOfSize:fontSize weight:NSFontWeightRegular];
    } else {
        font = [NSFont fontWithName:fontName size:fontSize];
    }

    return font;
}

- (void)parseOptions:(const char *[])argv withLength:(int)argc {
    for (int i = 1; i < argc; i++) {
        NSString *arg = [NSString stringWithUTF8String:argv[i]];
        if ([arg isEqualToString:@"-i"]) {
            [self setCaseInsensitive:YES];
        } else if ([arg isEqualToString:@"-b"]) {
            [self setBottom:YES];
        } else if ([arg isEqualToString:@"-l"] && i + 1 < argc) {
            int lines = atoi(argv[++i]);
            [self setLines:lines];
        } else if ([arg isEqualToString:@"-fn"] && i + 1 < argc) {
            [self setFontString:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-nb"] && i + 1 < argc) {
            [self setBgColorHex:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-nf"] && i + 1 < argc) {
            [self setFgColorHex:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-p"] && i + 1 < argc) {
            [self setPrompt:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-sb"] && i + 1 < argc) {
            [self setSelectedBgColorHex:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-sf"] && i + 1 < argc) {
            [self setSelectedFgColorHex:[NSString stringWithUTF8String:argv[++i]]];
        } else if ([arg isEqualToString:@"-v"] || [arg isEqualToString:@"--version"]) {
            [self setWantsVersion:YES];
        } else if ([arg isEqualToString:@"-h"] || [arg isEqualToString:@"--help"]) {
            [self setWantsHelp:YES];
        }
    }
}

- (void)parseStdin {
    struct timeval timeout;
    fd_set readfds;

    // Set up the file descriptor set.
    FD_ZERO(&readfds);
    FD_SET(STDIN_FILENO, &readfds);

    // Set timeout to 0 to make it non-blocking (immediate return).
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;

    int result = select(STDIN_FILENO + 1, &readfds, NULL, NULL, &timeout);

    if (result <= 0 || !FD_ISSET(STDIN_FILENO, &readfds)) {
        // No input available or an error occurred.
        return;
    }

    char buffer[1024];
    NSString *inputString = @"";
    if (fgets(buffer, sizeof(buffer), stdin) != NULL) {
        inputString = [NSString stringWithUTF8String:buffer];
    }

    NSArray *elements = [inputString componentsSeparatedByString:@"\n"];

    // remove the last element of the array, if it's an empty string
    if ([elements count] > 0 && [[elements objectAtIndex:[elements count] - 1] isEqual:@""]) {
        elements = [elements subarrayWithRange:NSMakeRange(0, [elements count] - 1)];
    }

    [self setOptions:elements];
}

@end
