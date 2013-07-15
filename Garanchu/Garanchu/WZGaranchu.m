//
//  WZGaranchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaranchu.h"

@implementation WZGaranchu

{
    WZGaraponWeb *_garaponWeb;
    WZGaraponTv *_garaponTv;
}

- (id)init
{
    self = [super init];
    if (self) {
        _garaponWeb = [[WZGaraponWeb alloc] init];
        _garaponWeb.devId = GARAPON_DEV_ID;
        
        _garaponTv = [[WZGaraponTv alloc] init];
        _garaponTv.devId = GARAPON_DEV_ID;
    }
    return self;
}

+ (WZGaranchu *)current
{
    static WZGaranchu *current = nil;
    if (!current) {
        current = [[WZGaranchu alloc] init];
    }
    return current;
}

- (void)storeTvAddress:(NSDictionary *)dict
{
    WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:dict];
    NSString *privateAddress = [wrap stringValueWithKey:@"pipaddr" defaultValue:nil];
    NSString *globalAddress = [wrap stringValueWithKey:@"gipaddr" defaultValue:nil];
    NSInteger globalPort = [wrap intgerValueWithKey:@"port" defaultValue:80];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:privateAddress forKey:@"garaponTvPrivateAddress"];
    [userDefaults setValue:globalAddress forKey:@"garaponTvGlobalAddress"];
    [userDefaults setInteger:globalPort forKey:@"garaponTvGlobalPort"];
    [userDefaults synchronize];
}

@end
