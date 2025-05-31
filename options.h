#import <Cocoa/Cocoa.h>

@interface Options : NSObject

@property (nonatomic, assign) BOOL wantsVersion;
@property (nonatomic, assign) BOOL wantsHelp;
@property (nonatomic, strong) NSString *prompt;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *fontString;
@property (nonatomic, strong) NSString *fgColorHex;
@property (nonatomic, strong) NSString *bgColorHex;
@property (nonatomic, strong) NSString *selectedFgColorHex;
@property (nonatomic, strong) NSString *selectedBgColorHex;
@property (nonatomic, assign) BOOL caseInsensitive;
@property (nonatomic, assign) int lines;
@property (nonatomic, assign) BOOL bottom;

- (NSColor *)fgColor;
- (NSColor *)bgColor;
- (NSColor *)selectedFgColor;
- (NSColor *)selectedBgColor;
- (NSFont *)font;

- (void)parseOptions:(const char *[])argv withLength:(int)argc;
- (void)parseStdin;

@end
