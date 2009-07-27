//
//  DeviceDNAAppDelegate.h
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDNAAppDelegate : NSObject <UIApplicationDelegate, 
                                       UITabBarControllerDelegate>
{
@private
    IBOutlet UIWindow *_window;
    IBOutlet UINavigationController *_navigationController;
}

@end
