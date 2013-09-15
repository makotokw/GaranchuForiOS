//
//  WZGaranchu.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WZGarapon/WZGarapon.h>

@interface WZGaranchu : NSObject

@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;
@property (weak, readwrite) WZGaraponTvProgram *watchingProgram;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (WZGaranchu *)current;

- (void)setup;
- (void)storeTvAddress:(NSDictionary *)dict;

- (void)saveManagedObjectContext;

@end
