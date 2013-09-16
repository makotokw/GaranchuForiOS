//
//  WatchHistory.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZCoreData.h"
#import "WatchHistory.h"
#import "VideoProgram.h"

@implementation WatchHistory

@dynamic gtvid;
@dynamic watchdate;
@dynamic recorddate;
@dynamic position;
@dynamic done;
@dynamic program;

+ (WatchHistory *)findByGtvid:(NSString *)gtvid
{
    WatchHistory *record = nil;
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WatchHistory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gtvid == %@", gtvid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0) {
        record = fetchedObjects[0];
    }
    
    return record;
}

+ (WatchHistory *)findOrCreateByProgram:(WZGaraponTvProgram *)program
{
    WatchHistory *record = [self findByGtvid:program.gtvid];
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    if (!record) {
        record = [NSEntityDescription
                  insertNewObjectForEntityForName:@"WatchHistory"
                  inManagedObjectContext:context];
        record.gtvid = program.gtvid;
        record.position = @0;
        record.done = @NO;
        record.recorddate = program.startdate;
        record.program = [VideoProgram findOrCreateByProgram:program];
    }
    
    return record;
}

+ (NSUInteger)count
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WatchHistory"
                                   inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    
    NSError* error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound) {
        count = 0;
    }    
    return count;
}

+ (NSArray *)findWithLimit:(NSInteger)limit
{
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WatchHistory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watchdate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchLimit:limit];    
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

+ (void)updateHistoryWithProgram:(WZGaraponTvProgram *)program position:(NSTimeInterval)position done:(BOOL)done
{
    WatchHistory *history = [self findOrCreateByProgram:program];
    history.position = [NSNumber numberWithFloat:position];
    history.done = [NSNumber numberWithBool:done];
    history.watchdate = [NSDate date];
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    }
}

+ (NSUInteger)deleteAll
{
    NSUInteger count = 0;
    
    WZCoreData *data = [WZCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"WatchHistory" inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!error) {
        for (NSManagedObject *object in fetchedObjects) {
            [context deleteObject:object];
        }        
        if (![context save:&error]) {
            // Handle the error.
            NSLog(@"Error: %@", error);
        } else {
            count = fetchedObjects.count;
        }
    }
    
    return count;
}

@end
