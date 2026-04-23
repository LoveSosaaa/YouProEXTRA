#import <Foundation/Foundation.h>

%hook YouPro_DownloadManager

- (NSString *)arabicQualityLabel:(NSString *)label {
    NSString *result = %orig;
    if (!result) return result;

    NSDictionary *map = @{
        @"منخفضة": @"Low",
        @"متوسطة": @"Medium",
        @"عالية": @"High",
        @"جودة منخفضة": @"Low Quality",
        @"جودة متوسطة": @"Medium Quality",
        @"جودة عالية": @"High Quality"
    };

    return map[result] ?: result;
}

%end
