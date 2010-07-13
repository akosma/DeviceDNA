//
//  SystemInfoController.m
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "SystemInfoController.h"
#import <iAd/iAd.h>

@interface SystemInfoController ()

@property (nonatomic, retain) UITableViewCell *uuidCell;
@property (nonatomic, retain) UITableViewCell *nameCell;
@property (nonatomic, retain) UITableViewCell *systemCell;
@property (nonatomic, retain) UITableViewCell *modelCell;
@property (nonatomic, retain) MFMailComposeViewController *mailComposer;
@property (nonatomic, assign) UIDevice *device;
@property (nonatomic) SystemInfoItems exposedInfoMask;
@property (nonatomic, copy) NSArray *cells;

- (BOOL)exposesInformation:(SystemInfoItems)item;
- (void)changeUIElements;
- (void)unselect;
- (void)showAdvertising;

@end

@implementation SystemInfoController

@synthesize tableView = _tableView;
@synthesize sendButton = _sendButton;
@synthesize uuidCell = _uuidCell;
@synthesize nameCell = _nameCell;
@synthesize systemCell = _systemCell;
@synthesize modelCell = _modelCell;
@synthesize cells = _cells;
@synthesize mailComposer = _mailComposer;
@synthesize device = _device;
@synthesize exposedInfoMask = _exposedInfoMask;

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    [_tableView release];
    _tableView = nil;
    [_sendButton release];
    _sendButton = nil;
    [_uuidCell release];
    _uuidCell = nil;
    [_nameCell release];
    _nameCell = nil;
    [_systemCell release];
    _systemCell = nil;
    [_modelCell release];
    _modelCell = nil;
    [_cells release];
    _cells = nil;
    [_mailComposer release];
    _mailComposer = nil;
    _device = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)send:(id)sender
{
    if (self.mailComposer == nil)
    {
        self.mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
        self.mailComposer.mailComposeDelegate = self;
    }

    NSString *messageTitle = NSLocalizedString(@"System information sent by DeviceDNA", @"Title of the e-mail message");
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"<p><strong>%@:</strong></p><ul>", messageTitle];
    
    if ([self exposesInformation:SystemInfoUUID])
    {
        NSString *uniqueIdentifierString = NSLocalizedString(@"Unique Device Identifier", @"The 'Unique Device Identifier' phrase");
        [body appendFormat:@"<li>%@ (UDID): <strong>%@</strong></li>", uniqueIdentifierString, self.device.uniqueIdentifier];
    }
    if ([self exposesInformation:SystemInfoName])
    {
        NSString *nameString = NSLocalizedString(@"Device Name", @"The 'Name' word");
        [body appendFormat:@"<li>%@: <strong>%@</strong></li>", nameString, self.device.name];
    }
    if ([self exposesInformation:SystemInfoOS])
    {
        NSString *iPhoneOSString = NSLocalizedString(@"iPhone OS Version", @"The 'iPhone OS' phrase");
        [body appendFormat:@"<li>%@: <strong>%@ %@</strong></li>", iPhoneOSString, self.device.systemName, self.device.systemVersion];
    }
    if ([self exposesInformation:SystemInfoModel])
    {
        NSString *modelString = NSLocalizedString(@"Device Model", @"The 'Model' word");
        [body appendFormat:@"<li>%@: <strong>%@</strong></li>", modelString, self.device.localizedModel];        
    }
    NSString *allRightsReserved = NSLocalizedString(@"All Rights Reserved", @"The 'all rights reserved' phrase");
    [body appendFormat:@"</ul><p><strong>DeviceDNA</strong> © Copyright 2009 <a href=\"http://akosma.com/\">akosma software</a>. %@.</p>", allRightsReserved];
    
    [self.mailComposer setSubject:messageTitle];
    [self.mailComposer setMessageBody:body isHTML:YES];
    self.mailComposer.navigationBar.barStyle = UIBarStyleBlack;

    [self presentModalViewController:self.mailComposer animated:YES];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
    [self.mailComposer dismissModalViewControllerAnimated:YES];
    self.mailComposer = nil;
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *allRightsReserved = NSLocalizedString(@"All Rights Reserved", @"The 'all rights reserved' phrase");
    NSString *instructions = NSLocalizedString(@"Select the values to send\nand press the message button", @"Instructions of use");
    return [NSString stringWithFormat:@"%@\n\nDeviceDNA © Copyright 2009 akosma\nsoftware - %@", instructions, allRightsReserved];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) 
    {
        case 0:
            cell = self.uuidCell;
            break;
            
        case 1:
            cell = self.nameCell;
            break;
            
        case 2:
            cell = self.systemCell;
            break;
            
        case 3:
            cell = self.modelCell;
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // This toggles the value for the selected cell
    // as shown in http://www.dylanleigh.net/notes/c-cpp-tricks.html
    self.exposedInfoMask ^= cell.tag;
    [self changeUIElements];
    
    // This makes a visual deselection after 1/10th of second
    [self performSelector:@selector(unselect) withObject:nil afterDelay:0.1];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    self.tableView.rowHeight = 60;
    
    self.device = [UIDevice currentDevice];
    self.exposedInfoMask = SystemInfoUUID | SystemInfoName | SystemInfoOS | SystemInfoModel;
    NSString *identifier = @"SystemInformationCell";
    
    NSString *uniqueIdentifierString = NSLocalizedString(@"Unique Device Identifier", @"The 'Unique Device Identifier' phrase");
    NSString *nameString = NSLocalizedString(@"Device Name", @"The 'Name' word");
    NSString *iPhoneOSString = NSLocalizedString(@"iPhone OS Version", @"The 'iPhone OS' phrase");
    NSString *modelString = NSLocalizedString(@"Device Model", @"The 'Model' word");
    NSString *sendButtonString = NSLocalizedString(@"Send", @"The label of the 'Send' button");

    self.uuidCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    self.uuidCell.textLabel.text = self.device.uniqueIdentifier;
    self.uuidCell.detailTextLabel.text = uniqueIdentifierString;
    self.uuidCell.tag = SystemInfoUUID;
    
    self.nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    self.nameCell.textLabel.text = self.device.name;
    self.nameCell.detailTextLabel.text = nameString;
    self.nameCell.tag = SystemInfoName;
    
    self.systemCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    self.systemCell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.device.systemName, self.device.systemVersion];
    self.systemCell.detailTextLabel.text = iPhoneOSString;
    self.systemCell.tag = SystemInfoOS;
    
    self.modelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    self.modelCell.textLabel.text = self.device.localizedModel;
    self.modelCell.detailTextLabel.text = modelString;
    self.modelCell.tag = SystemInfoModel;
    
    self.cells = [NSArray arrayWithObjects:self.uuidCell, self.nameCell, self.systemCell, self.modelCell, nil];
    self.sendButton.title = sendButtonString;
    
    [self showAdvertising];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self changeUIElements];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Private methods

- (BOOL)exposesInformation:(SystemInfoItems)item
{
    return (self.exposedInfoMask & item) == item;
}

- (void)changeUIElements
{
    for (UITableViewCell *cell in self.cells)
    {
        BOOL exposed = [self exposesInformation:cell.tag];
        cell.accessoryType = (exposed) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    self.sendButton.enabled = (self.exposedInfoMask != SystemInfoNone);
}

- (void)unselect
{
    // Unselect the selected row if any
    // http://forums.macrumors.com/showthread.php?t=577677
    NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
    if (selection)
    {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

- (void)showAdvertising
{
    Class klass = NSClassFromString(@"ADBannerView");
    if (klass)
    {
        ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, 366.0, 320.0, 50.0)];
        adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
        [self.view addSubview:adView];
    }
}
    
@end
