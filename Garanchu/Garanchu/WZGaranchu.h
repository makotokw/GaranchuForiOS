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
@property (weak, readwrite) WZGaraponTvProgram *watchingProgram;
@property (readwrite) NSURL *initialURL;

+ (WZGaranchu *)current;

- (void)setup;
- (void)storeTvAddress:(NSDictionary *)dict;

@end
