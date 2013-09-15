//
//  SearchCondition.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZCoreData.h"
#import "SearchCondition.h"
#import "SearchConditionList.h"

@implementation SearchCondition

@dynamic ch;
@dynamic genre01;
@dynamic genre02;
@dynamic keyword;
@dynamic searchdate;
@dynamic title;
@dynamic list;

+ (SearchCondition *)conditionWithKeyword:(NSString *)keyword addTo:(SearchConditionList *)list
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    SearchCondition *condtion = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"SearchCondition"
                                 inManagedObjectContext:context];
    condtion.keyword = keyword;
    
    [list addItemsObject:condtion];
    
    return condtion;
}

+ (void)deleteWithCondition:(SearchCondition *)condition
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    [context deleteObject:condition];
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    }
}

+ (void)updatedSearchedAtWithCondition:(SearchCondition *)condition
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    condition.searchdate = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    }
}

@end
