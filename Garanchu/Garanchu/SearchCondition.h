//
//  SearchCondition.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SearchCondition : NSManagedObject

@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * genre01;
@property (nonatomic, retain) NSNumber * genre02;
@property (nonatomic, retain) NSNumber * ch;
@property (nonatomic, retain) NSDate * searched_at;

@end
