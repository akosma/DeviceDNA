//
//  SystemInfoController.h
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

typedef enum {
    SystemInfoNone   = 0,
    SystemInfoUUID   = 1 << 0,
    SystemInfoName   = 1 << 1,
    SystemInfoOS     = 1 << 2,
    SystemInfoModel  = 1 << 3
} SystemInfoItems;

@class AboutController;

@interface SystemInfoController : UIViewController <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    MFMailComposeViewControllerDelegate>
{
@private
    UITableView *_tableView;
    UIBarButtonItem *_sendButton;

    UITableViewCell *_uuidCell;
    UITableViewCell *_nameCell;
    UITableViewCell *_systemCell;
    UITableViewCell *_modelCell;
    NSArray *_cells;

    MFMailComposeViewController *_mailComposer;

    UIDevice *_device;
    SystemInfoItems _exposedInfoMask;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)send:(id)sender;

@end
