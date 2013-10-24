//
//  NSURL+QueryString.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryString)
+ (NSString *)urlEncode:(NSString *)text;
+ (NSString *)urlDecode:(NSString *)text;
+ (NSString *)buildParameters:(NSDictionary *)params;
- (NSURL *)URLByAppendingQueryString:(NSString *)query overwrite:(BOOL)overwrite;
- (NSURL *)URLByAppendingParameters:(NSDictionary *)params overwrite:(BOOL)overwrite;
- (NSDictionary *)queryAsDictionary;
@end
