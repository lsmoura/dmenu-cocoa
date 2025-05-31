#import "nsstring+fuzzy.h"

@implementation NSString (Fuzzy)

- (BOOL)fuzzyMatch:(NSString *)pattern {
    return [NSString isFuzzyMatch:pattern inString:self];
}

- (BOOL)caseInsensitiveFuzzyMatch:(NSString *)pattern {
    pattern = [pattern lowercaseString];
    NSString *text = [self lowercaseString];

    return [NSString isFuzzyMatch:pattern inString:text];
}


+ (BOOL)isFuzzyMatch:(NSString *)pattern inString:(NSString *)text {
    NSUInteger patternIndex = 0;
    NSUInteger textIndex = 0;

    while (patternIndex < pattern.length && textIndex < text.length) {
        unichar pChar = [pattern characterAtIndex:patternIndex];
        unichar tChar = [text characterAtIndex:textIndex];

        if (pChar == tChar) {
            patternIndex++;
        }
        textIndex++;
    }

    return patternIndex == pattern.length;
}

@end
