//
//  WatchHistory.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WZYGaraponTvProgram;

@interface WatchHistory : NSManagedObject

@property (nonatomic, retain) NSString * gtvid;
@property (nonatomic, retain) NSDate * watchdate;
@property (nonatomic, retain) NSDate * recorddate;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSManagedObject *program;

+ (WatchHistory *)findByGtvid:(NSString *)gtvid;
+ (NSUInteger)count;
+ (NSArray *)findWithLimit:(NSInteger)limit;
+ (NSArray *)findRecentSince:(NSDate *)date;
+ (void)updateHistoryWithProgram:(WZYGaraponTvProgram *)program position:(NSTimeInterval)position done:(BOOL)done;
+ (NSUInteger)deleteAll;

@end
