#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *YouProEnglishify(NSString *text) {
    if (!text || ![text isKindOfClass:[NSString class]]) return text;

    // Quality labels
    if ([text containsString:@"4K"]) return @"4K";
    if ([text containsString:@"2160p"]) return @"2160p";
    if ([text containsString:@"1440p"]) return @"1440p";
    if ([text containsString:@"1080p"]) return @"1080p";
    if ([text containsString:@"720p"]) return @"720p";
    if ([text containsString:@"480p"]) return @"480p";
    if ([text containsString:@"360p"]) return @"360p";
    if ([text containsString:@"240p"]) return @"240p";
    if ([text containsString:@"144p"]) return @"144p";

    // Title + buttons
    if ([text isEqualToString:@"جودة التنزيل"]) return @"Download Quality";
    if ([text isEqualToString:@"تنزيل"]) return @"Download";
    if ([text isEqualToString:@"إلغاء"]) return @"Cancel";

    // Convert Arabic MB to MB
    if ([text containsString:@"م.ب"]) {
        text = [text stringByReplacingOccurrencesOfString:@"م.ب" withString:@"MB"];
    }

    // Convert MB to GB using 1024
    if ([text containsString:@"MB"]) {
        NSScanner *scanner = [NSScanner scannerWithString:text];
        double value = 0;

        if ([scanner scanDouble:&value]) {
            if (value >= 1024.0) {
                double gb = value / 1024.0;
                return [NSString stringWithFormat:@"%.1f GB", gb];
            } else {
                return [NSString stringWithFormat:@"%.0f MB", value];
            }
        }
    }

    return text;
}

static void YouProFixViewTexts(UIView *view) {
    if (!view) return;

    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.text = YouProEnglishify(label.text);
    } else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;

        NSArray *states = @[
            @(UIControlStateNormal),
            @(UIControlStateHighlighted),
            @(UIControlStateSelected),
            @(UIControlStateDisabled)
        ];

        for (NSNumber *stateNumber in states) {
            UIControlState state = (UIControlState)[stateNumber unsignedIntegerValue];
            NSString *title = [button titleForState:state];
            if (title) {
                [button setTitle:YouProEnglishify(title) forState:state];
            }
        }

        NSString *currentTitle = button.currentTitle;
        if (currentTitle) {
            NSString *fixed = YouProEnglishify(currentTitle);
            [button setTitle:fixed forState:UIControlStateNormal];
            [button setTitle:fixed forState:UIControlStateHighlighted];
            [button setTitle:fixed forState:UIControlStateSelected];
            [button setTitle:fixed forState:UIControlStateDisabled];
        }
    }

    for (UIView *subview in view.subviews) {
        YouProFixViewTexts(subview);
    }
}

%hook YouPro_DownloadManager

- (NSString *)arabicQualityLabel:(NSString *)label {
    NSString *result = %orig;
    return YouProEnglishify(result);
}

%end

%hook YouProQualitySheet

- (void)viewDidLoad {
    %orig;
    UIView *rootView = [(UIViewController *)self view];
    YouProFixViewTexts(rootView);
}

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    UIView *rootView = [(UIViewController *)self view];
    YouProFixViewTexts(rootView);
}

%end
