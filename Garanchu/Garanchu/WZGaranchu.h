//
//  WZGaranchu.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZGarapon/WZGarapon.h>

FOUNDATION_EXPORT NSString *WZGarancuLocalizedString(NSString *key);

@interface WZGaranchu : NSObject

@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;
@property (weak, readwrite) WZGaraponTvProgram *watchingProgram;
@property (readwrite) NSURL *initialURL;

+ (WZGaranchu *)current;
+ (void)showAlertWithError:(NSError *)error;

- (void)setup;
- (void)storeTvAddress:(NSDictionary *)dict;

@end
