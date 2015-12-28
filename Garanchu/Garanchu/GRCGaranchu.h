//
//  GRCGaranchu.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZYGarapon/WZYGarapon.h>

FOUNDATION_EXPORT NSString *GRCLocalizedString(NSString *key);

@interface GRCGaranchu : NSObject

@property (readonly) WZYGaraponWeb *garaponWeb;
@property (readonly) WZYGaraponTv *garaponTv;
@property (weak, readwrite) WZYGaraponTvProgram *watchingProgram;
@property (readwrite) NSURL *initialURL;

@property (readonly) BOOL isTablet;
@property (readonly) BOOL isPhone;

+ (GRCGaranchu *)current;
+ (void)showAlertWithError:(NSError *)error;

- (void)setup;
- (void)storeTvAddress:(NSDictionary *)dict;

@end
