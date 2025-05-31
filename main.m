#import "config.h"
#import "app_delegate.h"
#import "options.h"

#import "nscolor+hex.h"

int main(int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    Options *o = [[Options alloc] init];
    [o parseOptions:argv withLength:argc];

    if ([o wantsVersion]) {
        printf("%s version %s\n", argv[0], VERSION);
        [o release];
        return 0;
    }
    if ([o wantsHelp]) {
        printf("Usage: %s [options]\n", argv[0]);
        printf("Options:\n");
        printf("  -i                Case insensitive matching\n");
        printf("  -b                Show at the bottom of the screen\n");
        printf("  -l <lines>        Number of lines to show\n");
        printf("  -fn <font>        Font to use (e.g., 'Helvetica:size=12')\n");
        printf("  -nb <color>       Background color (hex)\n");
        printf("  -nf <color>       Foreground color (hex)\n");
        printf("  -p <prompt>       Prompt text\n");
        printf("  -sb <color>       Selected background color (hex)\n");
        printf("  -sf <color>       Selected foreground color (hex)\n");
        printf("  -v, --version     Show version information\n");
        printf("  -h, --help        Show this help message\n");
        [o release];
        return 0;
    }
    [o parseStdin];

    NSApplication *app = [NSApplication sharedApplication];

    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    [appDelegate updateOptions:o];
    [app setDelegate:appDelegate];
    [app run];

    [pool release];

    return 0;
}