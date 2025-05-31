#import "app_delegate.h"
#import "window.h"
#import "options_view.h"
#import "nsstring+fuzzy.h"

@implementation AppDelegate {
    NSWindow *_window;
    NSView *_contents;
    NSTextField *_promptLabel;
    NSTextField *_input;
    OptionsView *_optionsView;
    NSFont *_font;
    NSArray *_options;

    NSColor *_fgColor;
    NSColor *_bgColor;
    NSColor *_selectedFgColor;
    NSColor *_selectedBgColor;

    NSString *filter;
    NSArray *filteredOptions;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *window = [self window];

    [window setLevel:NSModalPanelWindowLevel];

    [self resizeWindow];

    if ([self lines] > 0) {
        [window center];
    }
    [window makeKeyAndOrderFront:nil];

    // listen for keystrokes
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent *(NSEvent *event) {
        return [self eventHandler:event];
    }];

    NSApplication *app = [NSApplication sharedApplication];
    [app setActivationPolicy:NSApplicationActivationPolicyRegular];
    [app activateIgnoringOtherApps:YES];
}

- (void)resizeWindow {
    if ([self lines] == 0) {
        NSRect textBoundRect = [@"1234567890" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[self font]}];
        NSRect windowFrame = [[self window] frame];
        NSRect screenFrame = [[NSScreen mainScreen] frame];

        windowFrame.origin.x = 0;
        if ([self bottom]) {
            // handle dock
            NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
            BOOL dockIsOnBottom = (visibleFrame.origin.y > 0);
            CGFloat dockHeight = 0;
            if (dockIsOnBottom) {
                dockHeight = NSHeight(screenFrame) - NSHeight(visibleFrame);
            }
            windowFrame.origin.y = dockHeight;
        } else {
            windowFrame.origin.y = NSHeight(screenFrame) - NSHeight(textBoundRect);
        }
        windowFrame.size.width = NSWidth(screenFrame);
        windowFrame.size.height = NSHeight(textBoundRect);
        [[self window] setFrame:windowFrame display:YES animate:NO];
    } else {
        NSSize wantedSize = [[self optionsView] calculatedSize];
        [[self optionsView] setFrameSize:wantedSize];

        CGFloat originX = NSWidth([[self promptLabel] frame]);
        CGFloat originY = NSHeight([[self input] frame]);

        NSRect windowFrame = [[self window] frame];
        windowFrame.size.width = wantedSize.width + originX;
        windowFrame.size.height = wantedSize.height + originY;
        [[self window] setFrame:windowFrame display:YES animate:NO];
    }
}

- (NSWindow *)window {
    if (_window == nil) {
        NSRect frame = NSMakeRect(0, 0, 600, 400);
        _window = [[DMenuWindow alloc] initWithContentRect:frame
                                                 styleMask:NSWindowStyleMaskBorderless
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
        [_window setBackgroundColor:[self bgColor]];
        [_window setTitle:@"dmenu"];
        [_window setAcceptsMouseMovedEvents:YES];

        [self populateWindowContents:[_window contentView]];

        [_window makeFirstResponder:[self input]];
    }

    return _window;
}

- (void)populateWindowContents:(NSView *)contentView {
    NSTextField *prompt = [self promptLabel];
    [contentView addSubview:prompt];

    NSTextField *input = [self input];
    [contentView addSubview:input];

    OptionsView *contents = [self optionsView];
    [contentView addSubview:contents];

    [prompt setTranslatesAutoresizingMaskIntoConstraints:NO];
    [input setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contents setTranslatesAutoresizingMaskIntoConstraints:NO];
    if ([self lines] == 0) {
        NSRect textBoundRect = [@"1234567890" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[self font]}];
        NSRect screenFrame = [[NSScreen mainScreen] frame];
        NSRect contentsFrame = [contents frame];
        contentsFrame.size.width = NSWidth(screenFrame) - NSWidth([prompt frame]) - NSWidth([input frame]);
        contentsFrame.size.height = NSHeight(textBoundRect);

        NSLayoutConstraint *widthConstraint = [[contents widthAnchor] constraintEqualToConstant:NSWidth(screenFrame) - NSWidth([prompt frame]) - NSWidth([input frame])];
        [contents setFrame:contentsFrame];
        [widthConstraint setActive:YES];

        [NSLayoutConstraint activateConstraints:@[
            [[prompt leadingAnchor] constraintEqualToAnchor:[contentView leadingAnchor] constant:0],
            [[prompt trailingAnchor] constraintEqualToAnchor:[input leadingAnchor] constant:0],
            [[prompt topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:0],
            [[prompt bottomAnchor] constraintEqualToAnchor:[contentView bottomAnchor] constant:0],
            [[input leadingAnchor] constraintEqualToAnchor:[prompt trailingAnchor] constant:0],
            [[input trailingAnchor] constraintEqualToAnchor:[contents leadingAnchor] constant: 0],
            [[input topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:0],
            [[input bottomAnchor] constraintEqualToAnchor:[contentView bottomAnchor] constant:0],
            [[contents leadingAnchor] constraintEqualToAnchor:[input trailingAnchor] constant:0],
            [[contents trailingAnchor] constraintEqualToAnchor:[contentView trailingAnchor] constant:0],
            [[contents topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:0],
            [[contents bottomAnchor] constraintEqualToAnchor:[contentView bottomAnchor] constant:0],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [[prompt leadingAnchor] constraintEqualToAnchor:[contentView leadingAnchor] constant:0],
            [[prompt topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:0],
            [[input leadingAnchor] constraintEqualToAnchor:[prompt trailingAnchor] constant:0],
            [[input topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:0],
            [[input trailingAnchor] constraintEqualToAnchor:[contentView trailingAnchor] constant:0],
            [[contents leadingAnchor] constraintEqualToAnchor:[prompt trailingAnchor] constant:0],
            [[contents trailingAnchor] constraintEqualToAnchor:[contentView trailingAnchor] constant:0],
            [[contents topAnchor] constraintEqualToAnchor:[input bottomAnchor] constant:0],
            [[contents bottomAnchor] constraintEqualToAnchor:[contentView bottomAnchor] constant:0],
        ]];
    }
}

- (OptionsView *)optionsView {
    if (_optionsView == nil) {
        _optionsView = [[OptionsView alloc] init];
        [_optionsView setFont:[self font]];
        [_optionsView setOptions:[self options]];
        [_optionsView setWantsLayer:YES];
        [[_optionsView layer] setBackgroundColor:[[self bgColor] CGColor]];
        [_optionsView setFgColor:[self fgColor]];
        [_optionsView setBgColor:[self bgColor]];
        [_optionsView setLineCount:[self lines]];
    }

    return _optionsView;
}

- (NSTextField *)promptLabel {
    NSString *promptText = [self prompt];
    if (promptText == nil) {
        promptText = @"";
    }
    if (_promptLabel == nil) {
        _promptLabel = [NSTextField labelWithString:promptText];
        [_promptLabel setFont:[self font]];
        [_promptLabel setTextColor:[self fgColor]];

        if ([promptText isEqual:@""] == NO) {
            NSRect textBoundRect = [promptText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:[self font]}];
            [_promptLabel setFrame:textBoundRect];
        }
    }

    return _promptLabel;
}

- (NSTextField *)input {
    if (_input == nil) {
        _input = [[NSTextField alloc] init];
        [_input setBezeled:NO];
        [_input setEditable:YES];
        [_input setFocusRingType:NSFocusRingTypeNone];
        [_input setBackgroundColor:[self selectedBgColor]];
        [_input setTextColor:[self selectedFgColor]];
        [_input setNeedsLayout:YES];
        [_input layoutSubtreeIfNeeded];
        [_input setFont:[self font]];
        NSRect textBoundRect = [@"1234567890" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[self font]}];
        NSLayoutConstraint *widthConstraint = [[_input widthAnchor] constraintGreaterThanOrEqualToConstant:NSWidth(textBoundRect)];
        [widthConstraint setActive:YES];

        [_input setFrame:textBoundRect];
        [_input setDelegate:self];
    }

    return _input;
}

#define KeyCodeEscape 53
#define KeyCodeReturn 36
#define KeyCodeUpArrow 126
#define KeyCodeLeftArrow 123
#define KeyCodeDownArrow 125
#define KeyCodeRightArrow 124
#define KeyCodeTab 48

- (NSString*)outputMessage {
    if ([filteredOptions count] == 0) {
        return filter;
    }

    return [[self optionsView] selectedOption];
}

- (NSEvent*)eventHandler:(NSEvent *)event {
    if ([event type] != NSEventTypeKeyDown) {
        return event;
    }

    switch ([event keyCode]) {
        case KeyCodeEscape:
            if ([[self window] isKeyWindow]) {
                [[self window] close];
                return nil;
            }
            break;

        case KeyCodeReturn:
            fprintf(stdout, "%s\n", [[self outputMessage] UTF8String]);
            [[self window] close];
            return nil;

        case KeyCodeUpArrow:
        case KeyCodeLeftArrow:
            [[self optionsView] setSelectedIndex:[[self optionsView] selectedIndex] - 1];
            return nil;

        case KeyCodeDownArrow:
        case KeyCodeRightArrow:
            [[self optionsView] setSelectedIndex:[[self optionsView] selectedIndex] + 1];
            return nil;

        case KeyCodeTab:
            if ([event modifierFlags] & NSEventModifierFlagShift) {
                [[self optionsView] setSelectedIndex:[[self optionsView] selectedIndex] - 1];
            } else {
                [[self optionsView] setSelectedIndex:[[self optionsView] selectedIndex] + 1];
            }
            return nil;
    }

    return event;
}

- (void)setFont:(NSFont *)font {
    if (_font == font) {
        return;
    }

    _font = font;

    if (_promptLabel != nil) {
        [_promptLabel setFont:font];
    }
    if (_input != nil) {
        [_input setFont:font];
    }
    if (_optionsView != nil) {
        [_optionsView setFont:font];
    }
}

- (NSFont *)font {
    if (_font == nil) {
        _font = [NSFont systemFontOfSize:12];
    }

    return _font;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender {
    return YES;
}

- (void)setFilter:(NSString *)newValue {
    NSString *trimFilter = [newValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (filter == trimFilter) return;

    filter = trimFilter;
    if ([filter length] == 0) {
        [[self optionsView] setOptions:[self options]];
        filteredOptions = nil;
        return;
    }

    NSMutableArray *newOptions = [[NSMutableArray alloc] init];
    for (NSString *option in [self options]) {
        if ([option fuzzyMatch:filter]) {
            [newOptions addObject:option];
        }
    }

    // check if the array has changed
    BOOL hasChanged = NO;
    if (filteredOptions == nil) {
        hasChanged = YES;
    } else if ([newOptions count] != [filteredOptions count]) {
        hasChanged = YES;
    } else {
        for (NSUInteger i = 0; i < [filteredOptions count]; i++) {
            if ([filteredOptions objectAtIndex:i] != [newOptions objectAtIndex:i]) {
                hasChanged = YES;
                break;
            }
        }
    }

    if (hasChanged) {
        filteredOptions = newOptions;
        [[self optionsView] setOptions:filteredOptions];
    }
}

-(void)setOptions:(NSArray *)newOptions {
    if (_options == newOptions) {
        return;
    }

    if (_options != nil) {
        [_options release];
    }

    _options = newOptions;

    if (_options != nil) {
        [_options retain];
    }

    if (_optionsView != nil) {
        [_optionsView setOptions:_options];
    }
}

- (void)setLines:(int)l {
    _lines = l;

    if (_optionsView != nil) {
        [_optionsView setLineCount:_lines];
    }
}

- (void)updateOptions:(Options *)o {
    [self setFgColor:[o fgColor]];
    [self setBgColor:[o bgColor]];
    [self setSelectedFgColor:[o selectedFgColor]];
    [self setSelectedBgColor:[o selectedBgColor]];
    [self setPrompt:[o prompt]];
    [self setFont:[o font]];
    [self setOptions:[o options]];
    [self setLines:[o lines]];
    [self setBottom:[o bottom]];
}

// #mark color handling

- (void)setFgColor:(NSColor *)fgColor {
    if (_fgColor == fgColor) return;

    if (_fgColor != nil) {
        [_fgColor release];
    }

    _fgColor = fgColor;
    if (_fgColor != nil) {
        [_fgColor retain];
    }

    if (_promptLabel != nil) {
        [_promptLabel setTextColor:_fgColor];
    }
    if (_optionsView != nil) {
        [_optionsView setFgColor:_fgColor];
    }
}

- (NSColor *)fgColor {
    if (_fgColor != nil) {
        return _fgColor;
    }

    return [NSColor whiteColor];
}

- (void)setBgColor:(NSColor *)bgColor {
    if (_bgColor == bgColor) return;

    if (_bgColor != nil) {
        [_bgColor release];
    }

    _bgColor = bgColor;

    if (_bgColor != nil) {
        [_bgColor retain];
    }

    if (_optionsView != nil) {
        [[_optionsView layer] setBackgroundColor:[_bgColor CGColor]];
    }
}

- (NSColor *)bgColor {
    if (_bgColor != nil) {
        return _bgColor;
    }

    return [NSColor blackColor];
}

- (void)setSelectedFgColor:(NSColor *)color {
    if (_selectedFgColor == color) {
        return;
    }

    if (_selectedFgColor != nil) {
        [_selectedFgColor release];
    }

    _selectedFgColor = color;

    if (_selectedFgColor != nil) {
        [_selectedFgColor retain];
    }

    if (_optionsView != nil) {
        [_optionsView setSelectedFgColor:_selectedFgColor];
    }
}

- (NSColor *)selectedFgColor {
    if (_selectedFgColor != nil) {
        return _selectedFgColor;
    }

    return [self bgColor];
}

- (void)setSelectedBgColor:(NSColor *)color {
    if (_selectedBgColor == color) {
        return;
    }

    if (_selectedBgColor != nil) {
        [_selectedBgColor retain];
    }

    _selectedBgColor = color;

    if (_selectedBgColor != nil) {
        [_selectedBgColor retain];
    }

    if (_optionsView != nil) {
        [_optionsView setSelectedBgColor:_selectedBgColor];
    }
}

- (NSColor *)selectedBgColor {
    if (_selectedBgColor != nil) {
        return _selectedBgColor;
    }

    return [self fgColor];
}

// #mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    [self setFilter:[textField stringValue]];
}

@end