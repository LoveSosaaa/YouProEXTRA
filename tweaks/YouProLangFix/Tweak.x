#import <Foundation/Foundation.h>

%hook YouPro_DownloadManager

- (NSString *)arabicQualityLabel:(NSString *)label {
    NSString *result = %orig;
    if (!result) return result;

    NSDictionary *map = @{
        @"دقة فائقة (4K)": @"4K",
        @"دقة فائقة (2160p)": @"2160p",
        @"دقة عالية (1440p)": @"1440p",
        @"دقة عالية (1080p)": @"1080p",
        @"دقة عالية (720p)": @"720p",
        @"دقة متوسطة (480p)": @"480p",
        @"دقة متوسطة (360p)": @"360p",
        @"دقة منخفضة (240p)": @"240p",
        @"دقة منخفضة (144p)": @"144p",

        @"تنزيل": @"Download",
        @"إلغاء": @"Cancel"
    };

    return map[result] ?: result;
}

%end
