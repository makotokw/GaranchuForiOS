//
//  SearchCondition.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SearchConditionList;

@interface SearchCondition : NSManagedObject

@property (nonatomic, retain) NSNumber * ch;
@property (nonatomic, retain) NSNumber * genre01;
@property (nonatomic, retain) NSNumber * genre02;
@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSDate * searchdate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) SearchConditionList *list;


+ (SearchCondition *)conditionWithKeyword:(NSString *)keyword addTo:(SearchConditionList *)list;
+ (void)deleteWithCondition:(SearchCondition *)condition;
+ (void)updatedSearchedAtWithCondition:(SearchCondition *)condition;

@end
