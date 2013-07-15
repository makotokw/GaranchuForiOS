//
//  WZGaranchu.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZGarapon/WZGarapon.h>

@interface WZGaranchu : NSObject

@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;

+ (WZGaranchu *)current;

- (void)storeTvAddress:(NSDictionary *)dict;

@end
