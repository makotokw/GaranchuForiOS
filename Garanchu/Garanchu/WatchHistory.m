//
//  WatchHistory.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCCoreData.h"
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
    
    GRCCoreData *data = [GRCCoreData sharedInstance];
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

+ (WatchHistory *)findOrCreateByProgram:(WZYGaraponTvProgram *)program
{
    WatchHistory *record = [self findByGtvid:program.gtvid];
    
    GRCCoreData *data = [GRCCoreData sharedInstance];
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
    GRCCoreData *data = [GRCCoreData sharedInstance];
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
    GRCCoreData *data = [GRCCoreData sharedInstance];
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

+ (NSArray *)findRecentSince:(NSDate *)date
{
    GRCCoreData *data = [GRCCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WatchHistory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watchdate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *inPredicate =
    [NSPredicate predicateWithFormat: @"watchdate > %@", date];
    [fetchRequest setPredicate:inPredicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;

}

+ (void)updateHistoryWithProgram:(WZYGaraponTvProgram *)program position:(NSTimeInterval)position done:(BOOL)done
{
    WatchHistory *history = [self findOrCreateByProgram:program];
    history.position = [NSNumber numberWithFloat:position];
    history.done = [NSNumber numberWithBool:done];
    history.watchdate = [NSDate date];
    
    GRCCoreData *data = [GRCCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        GRCLogD(@"Error: %@", error);
    }
}

+ (NSUInteger)deleteAll
{
    NSUInteger count = 0;
    
    GRCCoreData *data = [GRCCoreData sharedInstance];
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
            GRCLogD(@"Error: %@", error);
        } else {
            count = fetchedObjects.count;
        }
    }
    
    return count;
}

@end
