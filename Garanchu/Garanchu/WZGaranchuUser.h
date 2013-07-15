//
//  WZGaranchuUser.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZGarapon/WZGarapon.h>

@interface WZGaranchuUser : NSObject

@property (readonly) NSString *garaponId;
@property (readonly) NSString *password;

+ (WZGaranchuUser *)defaultUser;

- (void)getGaraponTvAddress:(WZGaraponWeb *)garaponWeb garaponId:(NSString *)garaponId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;
- (NSDictionary *)hostAddressCache;

@end
