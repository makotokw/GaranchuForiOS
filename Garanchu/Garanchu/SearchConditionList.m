//
//  SearchConditionList.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZCoreData.h"
#import "SearchConditionList.h"
#import "SearchCondition.h"


@implementation SearchConditionList

@dynamic code;
@dynamic items;

- (void)deleteItems
{
    NSUInteger count = 0;
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSSet *items = self.items;
    for (NSManagedObject *item in items) {
        [context deleteObject:item];
    }
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    } else {
        count = items.count;
    }
}

+ (SearchConditionList *)findOrCreateByCode:(NSString *)code
{
    SearchConditionList *record = nil;
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchConditionList" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0) {
        record = fetchedObjects[0];
    } else {
        record = [NSEntityDescription
                insertNewObjectForEntityForName:@"SearchConditionList"
                inManagedObjectContext:context];
        record.code = code;
    }
    
    return record;
}

@end
