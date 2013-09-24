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

+ (NSArray *)findByList:(SearchConditionList *)list
{
    WZCoreData *data = [WZCoreData sharedInstance];
    
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchCondition" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"searchdate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY list == %@)", list];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

+ (void)deleteWithCondition:(SearchCondition *)condition
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    [context deleteObject:condition];
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        WZLogD(@"Error: %@", error);
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
        WZLogD(@"Error: %@", error);
    }
}

@end
