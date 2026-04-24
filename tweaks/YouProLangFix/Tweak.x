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

            NSAttributedString *attrTitle = [button attributedTitleForState:state];
            if (attrTitle.length > 0) {
                NSString *raw = attrTitle.string;
                NSString *fixed = YouProEnglishify(raw);

                if (![raw isEqualToString:fixed]) {
                    NSMutableAttributedString *newAttr =
                        [[NSMutableAttributedString alloc] initWithAttributedString:attrTitle];
                    [newAttr replaceCharactersInRange:NSMakeRange(0, newAttr.length)
                                          withString:fixed];
                    [button setAttributedTitle:newAttr forState:state];
                }
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

        NSAttributedString *currentAttr = button.currentAttributedTitle;
        if (currentAttr.length > 0) {
            NSString *raw = currentAttr.string;
            NSString *fixed = YouProEnglishify(raw);

            if (![raw isEqualToString:fixed]) {
                NSMutableAttributedString *newAttr =
                    [[NSMutableAttributedString alloc] initWithAttributedString:currentAttr];
                [newAttr replaceCharactersInRange:NSMakeRange(0, newAttr.length)
                                      withString:fixed];

                [button setAttributedTitle:newAttr forState:UIControlStateNormal];
                [button setAttributedTitle:newAttr forState:UIControlStateHighlighted];
                [button setAttributedTitle:newAttr forState:UIControlStateSelected];
                [button setAttributedTitle:newAttr forState:UIControlStateDisabled];
            }
        }

        NSString *text = button.currentTitle;

        if ([text isEqualToString:@"تنزيل"]) {
            [button setTitle:@"Download" forState:UIControlStateNormal];
            [button setTitle:@"Download" forState:UIControlStateHighlighted];
            [button setTitle:@"Download" forState:UIControlStateSelected];
            [button setTitle:@"Download" forState:UIControlStateDisabled];

            [button setAttributedTitle:nil forState:UIControlStateNormal];
            [button setAttributedTitle:nil forState:UIControlStateHighlighted];
            [button setAttributedTitle:nil forState:UIControlStateSelected];
            [button setAttributedTitle:nil forState:UIControlStateDisabled];
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

- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);

    UIView *rootView = [(UIViewController *)self view];
    YouProFixViewTexts(rootView);
}

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);

    UIView *rootView = [(UIViewController *)self view];
    YouProFixViewTexts(rootView);

    @try {
        UIButton *dlBtn = [(id)self valueForKey:@"dlBtn"];
        if ([dlBtn isKindOfClass:[UIButton class]]) {
            [dlBtn setTitle:@"Download" forState:UIControlStateNormal];
            [dlBtn setTitle:@"Download" forState:UIControlStateHighlighted];
            [dlBtn setTitle:@"Download" forState:UIControlStateSelected];
            [dlBtn setTitle:@"Download" forState:UIControlStateDisabled];

            [dlBtn setAttributedTitle:nil forState:UIControlStateNormal];
            [dlBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
            [dlBtn setAttributedTitle:nil forState:UIControlStateSelected];
            [dlBtn setAttributedTitle:nil forState:UIControlStateDisabled];

            if (dlBtn.titleLabel) {
                dlBtn.titleLabel.text = @"Download";
                dlBtn.titleLabel.attributedText = nil;
            }

            for (UIView *sub in dlBtn.subviews) {
                if ([sub isKindOfClass:[UILabel class]]) {
                    UILabel *lbl = (UILabel *)sub;
                    lbl.text = @"Download";
                    lbl.attributedText = nil;
                }
            }
        }

        UIButton *canBtn = [(id)self valueForKey:@"canBtn"];
        if ([canBtn isKindOfClass:[UIButton class]]) {
            [canBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            [canBtn setTitle:@"Cancel" forState:UIControlStateHighlighted];
            [canBtn setTitle:@"Cancel" forState:UIControlStateSelected];
            [canBtn setTitle:@"Cancel" forState:UIControlStateDisabled];

            if (canBtn.titleLabel) {
                canBtn.titleLabel.text = @"Cancel";
                canBtn.titleLabel.attributedText = nil;
            }
        }
    } @catch (NSException *e) {
    }
}

%end
