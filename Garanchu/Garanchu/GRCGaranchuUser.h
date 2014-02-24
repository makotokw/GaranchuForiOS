//
//  GRCGaranchuUser.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZYGarapon/WZYGarapon.h>

@interface GRCGaranchuUser : NSObject

@property (readonly) NSString *garaponId;
@property (readonly) NSString *password;

+ (GRCGaranchuUser *)defaultUser;

- (void)getGaraponTvAddress:(WZYGaraponWeb *)garaponWeb garaponId:(NSString *)garaponId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)clearGaraponIdAndPassword;
- (NSDictionary *)hostAddressCache;

@end
