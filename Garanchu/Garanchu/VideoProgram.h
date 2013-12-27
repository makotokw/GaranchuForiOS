//
//  VideoProgram.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VideoProgram : NSManagedObject

@property (nonatomic, retain) NSString * gtvid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * startdate;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * ch;

- (void)copyFromProgram:(WZGaraponTvProgram *)program;
- (void)copyToProgram:(WZGaraponTvProgram *)program;
+ (VideoProgram *)findOrCreateByProgram:(WZGaraponTvProgram *)program;

@end
