//
//  VideoProgram.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCCoreData.h"
#import "VideoProgram.h"

@implementation VideoProgram

@dynamic gtvid;
@dynamic title;
@dynamic startdate;
@dynamic duration;
@dynamic ch;

- (void)copyFromProgram:(WZYGaraponTvProgram *)program
{
    self.gtvid = program.gtvid;
    self.title = program.title;
    self.duration = [NSNumber numberWithFloat:program.duration];
    self.ch = [NSNumber numberWithInteger:program.ch];
    self.startdate = program.startdate;
}

- (void)copyToProgram:(WZYGaraponTvProgram *)program
{
    program.gtvid = self.gtvid;
    program.title = self.title;
    program.duration = self.duration.floatValue;
    program.ch = self.ch.integerValue;
    program.startdate = self.startdate;
}

+ (VideoProgram *)findOrCreateByProgram:(WZYGaraponTvProgram *)program
{
    VideoProgram *record = nil;
    
    GRCCoreData *data = [GRCCoreData sharedInstance];
    NSManagedObjectContext *context = data.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VideoProgram" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gtvid == %@", program.gtvid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0) {
        record = fetchedObjects[0];
    } else {
        record = [NSEntityDescription
                 insertNewObjectForEntityForName:@"VideoProgram"
                 inManagedObjectContext:context];
        [record copyFromProgram:program];        
    }
    
    return record;
}

@end
