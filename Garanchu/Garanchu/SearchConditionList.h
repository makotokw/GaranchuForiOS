//
//  SearchConditionList.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SearchCondition;

@interface SearchConditionList : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSSet *items;
@end

@interface SearchConditionList (CoreDataGeneratedAccessors)

- (void)addItemsObject:(SearchCondition *)value;
- (void)removeItemsObject:(SearchCondition *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

+ (SearchConditionList *)findOrCreateByCode:(NSString *)code;

@end
