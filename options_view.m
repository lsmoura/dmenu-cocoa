#import "options_view.h"
#import "nsstring+fuzzy.h"

@implementation OptionsView {
    NSUInteger offset;
    NSFont *_font;
}

- (id)init {
    self = [super init];
    if (self) {
        offset = 0;
    }

    return self;
}

- (void)setSelectedIndex:(NSUInteger)idx {
    if (idx < 0) {
        idx = 0;
    }
    if (idx > [self visibleOptions] - 1) {
        idx = [self visibleOptions] - 1;
    }

    if (_selectedIndex == idx) {
        return;
    }

    // needs scroll?
    if ([self verticalLayout]) {
        if (idx >= _lineCount+offset) {
            offset = idx - _lineCount + 1;
        } else if (idx < offset) {
            offset = idx;
        }
    } else {
        offset = 0;
    }

    _selectedIndex = idx;
    [self setNeedsDisplay:YES];
}

- (void)setOptions:(NSArray*)options {
    _options = options;
    _selectedIndex = 0;

    [self setNeedsDisplay:YES];

    if ([self lineCount] > 0) {
        [self recalculateSize];
    }
}

- (void)recalculateSize {
    NSSize calculatedSize = [self calculatedSize];
    [self setFrameSize:calculatedSize];
}

- (NSSize)calculatedSize {
    NSUInteger elementCount = [[self options] count];

    NSDictionary *attributes = @{
        NSFontAttributeName:[self font],
        NSForegroundColorAttributeName:[NSColor blackColor]
    };

    CGFloat totalHeight = 0.0;
    CGFloat maxWidth = 0.0;
    for (NSUInteger i = 0; i < elementCount; i++) {
        NSString *option = [[self options] objectAtIndex:i+offset];
        NSRect textBoundRect = [option boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes];

        if (i < _lineCount) {
            totalHeight += NSHeight(textBoundRect);
        }
        if (maxWidth < NSWidth(textBoundRect)) {
            maxWidth = NSWidth(textBoundRect);
        }
    }

    maxWidth += 4.0;

    return NSMakeSize(maxWidth, totalHeight);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSRect frame = [self frame];
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    NSUInteger elementCount = [[self options] count] - offset;
    if ([self verticalLayout]) {
        yPos = frame.size.height;
        elementCount = [self lineCount];
        if ([[self options] count] < elementCount) {
            elementCount = [[self options] count];
        }
    }

    for (NSUInteger i = 0; i < elementCount; i++) {
        NSUInteger currentOption = i + offset;
        NSString *option = [[self options] objectAtIndex:currentOption];
        NSRect textBoundRect = [option boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[self font]}];
        CGFloat currentY = yPos;
        CGFloat currentX = xPos;
        CGFloat boundsWidth = NSWidth(textBoundRect) + 4.0;
        if ([self verticalLayout]) {
            currentY -= NSHeight(textBoundRect);
            yPos = currentY;
            boundsWidth = NSWidth([self bounds]);
        } else {
            currentX = xPos;
            xPos = xPos + boundsWidth;
        }
        NSRect textRect = NSMakeRect(currentX, currentY, boundsWidth, NSHeight(textBoundRect));

        NSColor *fontColor = [self fgColor];
        if (currentOption == [self selectedIndex]) {
            [[self selectedBgColor] setFill];
            NSRectFill(textRect);
            fontColor = [self selectedFgColor];
        }
        textRect.origin.x += 2;
        [option drawInRect:textRect withAttributes:@{
            NSFontAttributeName:[self font],
            NSForegroundColorAttributeName:fontColor,
        }];
    }
}

- (NSUInteger)visibleOptions {
    return [[self options] count];
}

- (NSString *)selectedOption {
    return [[self options] objectAtIndex:[self selectedIndex]];
}

- (void)setFont:(NSFont *)font {
    if (_font == font) {
        return;
    }

    if (_font != nil) {
        [font release];
    }

    _font = font;

    if (_font != nil) {
        [font retain];
    }

    [self setNeedsDisplay:YES];
}

- (NSFont *)font {
    if (_font != nil) {
        return _font;
    }

    return [NSFont systemFontOfSize:12];
}

- (BOOL)verticalLayout {
    return [self lineCount] > 0;
}

// colours

- (NSColor *)fgColor {
    if (_fgColor != nil) {
        return _fgColor;
    }

    return [NSColor whiteColor];
}

- (NSColor *)bgColor {
    if (_bgColor != nil) {
        return _bgColor;
    }

    return [NSColor blackColor];
}

- (NSColor *)selectedFgColor {
    if (_selectedFgColor != nil) {
        return _selectedFgColor;
    }

    return [self bgColor];
}

- (NSColor *)selectedBgColor {
    if (_selectedBgColor != nil) {
        return _selectedBgColor;
    }

    return [self fgColor];
}

@end
