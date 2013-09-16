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

@synthesize initialURL = _initialURL;

+ (WZGaranchu *)current
{
    static WZGaranchu *current = nil;
    if (!current) {
        current = [[WZGaranchu alloc] init];
    }
    return current;
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

- (void)setup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[self applictionVersion] forKey:@"version"];

    NSString *tagValue = [userDefaults stringForKey:@"share_tag_line"];
    if (!tagValue) {
        [userDefaults setValue:@"見てる" forKey:@"share_tag_line"];
    }
}

- (NSString *)applictionVersion
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
#if DEBUG
    return [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"], info[(NSString *)kCFBundleVersionKey]];
#else
    return info[@"CFBundleShortVersionString"];
#endif
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
