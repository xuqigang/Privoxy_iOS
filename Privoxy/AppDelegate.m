//
//  AppDelegate.m
//  Privoxy
//
//  Created by 韩肖杰 on 2019/5/6.
//  Copyright © 2019 xuqg. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager *appleLocationManager;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self startLocation];
    return YES;
}

- (void)startLocation{
    self->appleLocationManager = [[CLLocationManager alloc] init];
    self->appleLocationManager.allowsBackgroundLocationUpdates = YES;
    self->appleLocationManager.pausesLocationUpdatesAutomatically = NO;
    self->appleLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self->appleLocationManager setDistanceFilter:kCLDistanceFilterNone];
    self->appleLocationManager.delegate = self;
    [self->appleLocationManager requestAlwaysAuthorization];
    [self->appleLocationManager startUpdatingLocation];
}
/** 苹果_用户位置更新后，会调用此函数 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    NSLog(@"success");
}

/** 苹果_定位失败后，会调用此函数 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"error");
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self->appleLocationManager startUpdatingLocation];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
