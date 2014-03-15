//
//  NSURL+QueryString.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryString)
+ (NSString *)grc_urlEncode:(NSString *)text;
+ (NSString *)grc_urlDecode:(NSString *)text;
+ (NSString *)grc_buildParameters:(NSDictionary *)params;
- (NSURL *)grc_URLByAppendingQueryString:(NSString *)query overwrite:(BOOL)overwrite;
- (NSURL *)grc_URLByAppendingParameters:(NSDictionary *)params overwrite:(BOOL)overwrite;
- (NSDictionary *)grc_queryAsDictionary;
@end
