#import <Cocoa/Cocoa.h>

@interface NSString (Fuzzy)

+ (BOOL)isFuzzyMatch:(NSString *)pattern inString:(NSString *)text;
- (BOOL)fuzzyMatch:(NSString *)string;
- (BOOL)caseInsensitiveFuzzyMatch:(NSString *)string;

@end
