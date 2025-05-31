#import <Cocoa/Cocoa.h>

@interface OptionsView : NSView

// @property (nonatomic, strong) NSFont *font;
@property (nonatomic, assign) NSUInteger selectedIndex;
// @property (nonatomic, strong) NSString *search;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) NSUInteger lineCount;
@property (nonatomic, strong) NSColor *fgColor;
@property (nonatomic, strong) NSColor *bgColor;
@property (nonatomic, strong) NSColor *selectedFgColor;
@property (nonatomic, strong) NSColor *selectedBgColor;

- (NSUInteger)visibleOptions;
- (NSString *)selectedOption;

- (void)setFont:(NSFont *)font;
- (NSFont*)font;

- (BOOL)verticalLayout;

// calculatedSize returns the width and height of the ideal
// view size, based on the current parameters
- (NSSize)calculatedSize;

@end
