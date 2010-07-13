//
//  DeviceDNAAppDelegate.m
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright akosma software 2009. All rights reserved.
//

#import "DeviceDNAAppDelegate.h"

@implementation DeviceDNAAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc 
{
    [_window release];
    _window = nil;
    [_navigationController release];
    _navigationController = nil;
    [super dealloc];
}

@end

