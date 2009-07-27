//
//  DeviceDNAAppDelegate.m
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright akosma software 2009. All rights reserved.
//

#import "DeviceDNAAppDelegate.h"

@implementation DeviceDNAAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [_window addSubview:_navigationController.view];
}

- (void)dealloc 
{
    [super dealloc];
}

@end

