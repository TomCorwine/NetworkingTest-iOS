//
//  TRKAppDelegate.m
//  Networking Test
//
//  Created by Tom Corwine on 7/30/12.
//  Copyright (c) 2012 Tracks Media. All rights reserved.
//

#import "TRKAppDelegate.h"

#import "TRKViewController.h"

@implementation TRKAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	
	TRKViewController *viewController = [[TRKViewController alloc] init];
	self.window.rootViewController = viewController;
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
