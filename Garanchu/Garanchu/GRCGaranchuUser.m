//
//  GRCGaranchuUser.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCGaranchuUser.h"

#import <SFHFKeychainUtils/SFHFKeychainUtils.h>

@implementation GRCGaranchuUser

{
    NSString *_garaponId;
}

@dynamic garaponId, password;

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _garaponId = [userDefaults stringForKey:@"garaponId"];
    }
    return self;
}

+ (GRCGaranchuUser *)defaultUser
{
    static GRCGaranchuUser *current = nil;
    if (!current) {
        current = [[GRCGaranchuUser alloc] init];
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
        _garaponId = garaponId;
        [userDefaults setValue:garaponId forKey:@"garaponId"];
        [userDefaults synchronize];
    } else {
         GRCLogD(@"WZGaranchuUser:storePassword:error = %@", error);
    }
}

- (void)deletePasswordForGaraponId:(NSString *)garaponId
{
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:garaponId andServiceName:GARAPON_SERVICE_NAME error:&error];
}


- (void)clearGaraponIdAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [self deletePasswordForGaraponId:_garaponId];
    [userDefaults removeObjectForKey:@"garaponId"];
    [userDefaults synchronize];
}

- (void)storeTvAddress:(NSDictionary *)dict
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:dict forKey:@"garaponTvAddress"];
    [userDefaults synchronize];
}

- (void)getGaraponTvAddress:(WZYGaraponWeb *)garaponWeb garaponId:(NSString *)garaponId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    __weak GRCGaranchuUser *me = self;
    [garaponWeb getGaraponTvAddressWithUserId:garaponId rawPassword:rawPassword completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            [me storeTvAddress:response];
            [me storePassword:rawPassword garaponId:garaponId];
        } else {
            GRCLogD(@"WZGaranchuUser:getGaraponTvAddress:error = %@", error);
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (NSString *)garaponId
{
    return _garaponId;
}

- (NSString *)password
{
    if (!_garaponId) {
        return nil;
    }
    NSError *error = nil;
    return [SFHFKeychainUtils getPasswordForUsername:_garaponId andServiceName:GARAPON_SERVICE_NAME error:&error];
}

@end
