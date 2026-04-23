#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *YouProEnglishify(NSString *text) {
    if (!text || ![text isKindOfClass:[NSString class]]) return text;

    if ([text containsString:@"4K"]) return @"4K";
    if ([text containsString:@"2160p"]) return @"2160p";
    if ([text containsString:@"1440p"]) return @"1440p";
    if ([text containsString:@"1080p"]) return @"1080p";
    if ([text containsString:@"720p"]) return @"720p";
    if ([text containsString:@"480p"]) return @"480p";
    if ([text containsString:@"360p"]) return @"360p";
    if ([text containsString:@"240p"]) return @"240p";
    if ([text containsString:@"144p"]) return @"144p";

    if ([text isEqualToString:@"جودة التنزيل"]) return @"Download Quality";
    if ([text isEqualToString:@"تنزيل"]) return @"Download";
    if ([text isEqualToString:@"إلغاء"]) return @"Cancel";

    if ([text containsString:@"م.ب"]) {
        return [text stringByReplacingOccurrencesOfString:@"م.ب" withString:@"MB"];
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
        NSString *normal = [button titleForState:UIControlStateNormal];
        if (normal) {
            [button setTitle:YouProEnglishify(normal) forState:UIControlStateNormal];
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
