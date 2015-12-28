//
//  GRCAppDelegate.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCAppDelegate.h"
#import "GRCStageViewController.h"
#import "GRCCoreData.h"

@implementation GRCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    GRCLogD(@"application:didFinishLaunchingWithOptions");
    GRCGaranchu *stage = [GRCGaranchu current];
    [stage setup];
            
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];

    NSString *initialViewControllerId = stage.isTablet ?
                                        @"tabletStageViewController"
                                        : @"phoneStageViewController";
    
    GRCStageViewController *stageViewController = [storyboard instantiateViewControllerWithIdentifier:initialViewControllerId];
    [stageViewController setUpBeforeLodingView];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = stageViewController;
    [self.window makeKeyAndVisible];
    
    // display status-bar in landscape for iOS8
    // http://stackoverflow.com/questions/24329503/on-ios8-displaying-my-app-in-landscape-mode-will-hide-the-status-bar-but-on-ios
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    GRCLogD(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    GRCLogD(@"applicationDidBecomeActive");
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        UIApplication *app = [UIApplication sharedApplication];
        app.statusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    GRCCoreData *data = [GRCCoreData sharedInstance];
    [data saveManagedObjectContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    GRCLogD(@"applicationOpenURL:%@", url);
    
    GRCGaranchu *stage = [GRCGaranchu current];
    stage.initialURL = url;
    
    return YES;
}

@end
