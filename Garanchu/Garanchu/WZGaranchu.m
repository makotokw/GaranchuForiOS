//
//  WZGaranchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaranchu.h"

// You shoud define your DevId to GARAPON_DEV_ID in WZGaranchuConfig.h
#import "WZGaranchuConfig.h"

#import <SDWebImage/SDImageCache.h>
#import <TestFlightSDK/TestFlight.h>

NSString *WZGarancuLocalizedString(NSString *key)
{
    return NSLocalizedString(key, nil);
}

@implementation WZGaranchu

{
    WZGaraponWeb *_garaponWeb;
    WZGaraponTv *_garaponTv;
}

@synthesize initialURL = _initialURL;

+ (void)showAlertWithError:(NSError *)error
{
    NSString *message = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"%@\n%@",
                                                             error.localizedDescription,
                                                             error.localizedRecoverySuggestion
                                                             ] : error.localizedDescription;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:WZGarancuLocalizedString(@"DefaultAlertCaption")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                                              otherButtonTitles:nil];
    [alertView show];
}

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[self applictionVersion] forKey:@"version"];

    NSString *tagValue = [userDefaults stringForKey:@"share_tag_line"];
    if (!tagValue) {
        [userDefaults setValue:@"見てる" forKey:@"share_tag_line"];
    }
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    cache.maxCacheAge = 86400;
    [cache cleanDisk];
    
    [self initializeTestFlightWithTeamToken:@"bdfbcd15-b247-47a5-9998-9feeb5fec037"];
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

static void WheezyHandleExceptions(NSException *exception)
{
    NSLog(@"This is where we save the application data during a exception");
    // Save application data on crash
}

static void WheezySignalHandler(int sig)
{
    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}

- (void)initializeTestFlightWithTeamToken:(NSString *)teamToken
{
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&WheezyHandleExceptions);
    // create the signal action structure
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &WheezySignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    
#if USE_TESTFLIGHT_SDK
#ifndef __IPHONE_7_0
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight takeOff:teamToken];
#endif
}


@end
