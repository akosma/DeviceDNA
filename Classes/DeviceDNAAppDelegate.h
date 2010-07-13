//
//  DeviceDNAAppDelegate.h
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDNAAppDelegate : NSObject <UIApplicationDelegate>
{
@private
    UIWindow *_window;
    UINavigationController *_navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
