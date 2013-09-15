//
//  WZGaranchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaranchu.h"

@implementation WZGaranchu

{
    WZGaraponWeb *_garaponWeb;
    WZGaraponTv *_garaponTv;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (WZGaranchu *)current
{
    static WZGaranchu *current = nil;
    if (!current) {
        current = [[WZGaranchu alloc] init];
    }
    return current;
}

- (id)init
{
    self = [super init];
    if (self) {
        _garaponWeb = [[WZGaraponWeb alloc] init];
        _garaponWeb.devId = GARAPON_DEV_ID;        
        _garaponTv = [[WZGaraponTv alloc] init];
        _garaponTv.devId = GARAPON_DEV_ID;
    }
    return self;
}

- (void)setup
{    
    [[NSUserDefaults standardUserDefaults] setObject:[self applictionVersion] forKey:@"version"];
}

- (NSString *)applictionVersion
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
#if DEBUG
    return [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"], info[(NSString *)kCFBundleVersionKey]];
#else
    return info[@"CFBundleShortVersionString"];
#endif
}

- (void)storeTvAddress:(NSDictionary *)dict
{
    WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:dict];
    NSString *privateAddress = [wrap stringValueWithKey:@"pipaddr" defaultValue:nil];
    NSString *globalAddress = [wrap stringValueWithKey:@"gipaddr" defaultValue:nil];
    NSInteger globalPort = [wrap intgerValueWithKey:@"port" defaultValue:80];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:privateAddress forKey:@"garaponTvPrivateAddress"];
    [userDefaults setValue:globalAddress forKey:@"garaponTvGlobalAddress"];
    [userDefaults setInteger:globalPort forKey:@"garaponTvGlobalPort"];
    [userDefaults synchronize];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Garanchu" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Garanchu.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // TODO:
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
        abort();
#endif
    }
    return _persistentStoreCoordinator;
}

- (void)saveManagedObjectContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // TODO:
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
            abort();
#endif
        }
    }
}


#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
