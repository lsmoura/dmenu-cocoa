#import <Cocoa/Cocoa.h>
#import "options.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>

@property (nonatomic, strong) NSString *prompt;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) int lines;
@property (nonatomic, assign) BOOL bottom;

@property (nonatomic, strong) NSColor *fgColor;
@property (nonatomic, strong) NSColor *bgColor;
@property (nonatomic, strong) NSColor *selectedBgColor;
@property (nonatomic, strong) NSColor *selectedFgColor;

- (void)setFont:(NSFont *)font;
- (NSFont *)font;
- (void)updateOptions:(Options *)options;

@end
