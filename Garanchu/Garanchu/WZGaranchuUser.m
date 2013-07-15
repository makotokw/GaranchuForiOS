//
//  WZGaranchuUser.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaranchuUser.h"

#import <SFHFKeychainUtils/SFHFKeychainUtils.h>

@implementation WZGaranchuUser

@dynamic garaponId, password;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (WZGaranchuUser *)defaultUser
{
    static WZGaranchuUser *current = nil;
    if (!current) {
        current = [[WZGaranchuUser alloc] init];
    }
    return current;
}

- (NSDictionary *)hostAddressCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults dictionaryForKey:@"garaponTvAddress"];
}

- (void)storePassword:(NSString *)password garaponId:(NSString *)garaponId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSError *error = nil;
    
    NSString *oldGaraponId = [userDefaults stringForKey:@"garaponId"];
    if (oldGaraponId && ![oldGaraponId isEqualToString:garaponId]) {
        [SFHFKeychainUtils deleteItemForUsername:oldGaraponId andServiceName:GARAPON_SERVICE_NAME error:&error];        
    }
    error = nil;
    [SFHFKeychainUtils storeUsername:garaponId andPassword:password forServiceName:GARAPON_SERVICE_NAME updateExisting:YES error:&error];
    if (!error) {
        [userDefaults setValue:garaponId forKey:@"garaponId"];
        [userDefaults synchronize];
    }
}

- (void)storeTvAddress:(NSDictionary *)dict
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:dict forKey:@"garaponTvAddress"];
    [userDefaults synchronize];
}

- (void)getGaraponTvAddress:(WZGaraponWeb *)garaponWeb garaponId:(NSString *)garaponId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    __weak WZGaranchuUser *me = self;
    [garaponWeb getGaraponTvAddressWithUserId:garaponId rawPassword:rawPassword completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {            
            [me storeTvAddress:response];
            [me storePassword:rawPassword garaponId:garaponId];
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (NSString *)garaponId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:@"garaponId"];
}

- (NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *garaponId = [userDefaults stringForKey:@"garaponId"];
    if (!garaponId) {
        return nil;
    }
    NSError *error = nil;
    return [SFHFKeychainUtils getPasswordForUsername:garaponId andServiceName:GARAPON_SERVICE_NAME error:&error];
}

@end
