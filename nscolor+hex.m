#import "nscolor+hex.h"

@implementation NSColor (Hex)

+ (NSColor *)fromHexString:(NSString *)hexString {
    NSString *cleanHex = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([cleanHex hasPrefix:@"#"]) {
        cleanHex = [cleanHex substringFromIndex:1];
    }

    unsigned int r = 0, g = 0, b = 0, a = 255;
    if (cleanHex.length == 8) {
        sscanf([cleanHex UTF8String], "%02x%02x%02x%02x", &r, &g, &b, &a);
    } else if (cleanHex.length == 6) {
        sscanf([cleanHex UTF8String], "%02x%02x%02x", &r, &g, &b);
    } else if (cleanHex.length == 3) {
        unsigned int ri, gi, bi;
        sscanf([cleanHex UTF8String], "%1x%1x%1x", &ri, &gi, &bi);
        r = (ri << 4) | ri;
        g = (gi << 4) | gi;
        b = (bi << 4) | bi;
    }

    return [NSColor colorWithCalibratedRed:r/255.0
                                     green:g/255.0
                                      blue:b/255.0
                                     alpha:a/255.0];
}

@end
