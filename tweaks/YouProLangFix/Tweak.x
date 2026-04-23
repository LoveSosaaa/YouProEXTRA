#import <Foundation/Foundation.h>

%hook YouPro_DownloadManager

- (NSString *)arabicQualityLabel:(NSString *)label {
    NSString *result = %orig;
    if (!result) return result;

    if ([result containsString:@"4K"]) return @"4K";
    if ([result containsString:@"2160p"]) return @"2160p";
    if ([result containsString:@"1440p"]) return @"1440p";
    if ([result containsString:@"1080p"]) return @"1080p";
    if ([result containsString:@"720p"]) return @"720p";
    if ([result containsString:@"480p"]) return @"480p";
    if ([result containsString:@"360p"]) return @"360p";
    if ([result containsString:@"240p"]) return @"240p";
    if ([result containsString:@"144p"]) return @"144p";

    return result;
}

%end
