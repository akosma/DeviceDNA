//
//  SystemInfoController.m
//  DeviceDNA
//
//  Created by Adrian on 7/27/2009.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "SystemInfoController.h"

@interface SystemInfoController (Private)
- (BOOL)exposesInformation:(SystemInfoItems)item;
- (void)changeUIElements;
- (void)unselect;
@end

@implementation SystemInfoController

#pragma mark -
#pragma mark dealloc

- (void)dealloc 
{
    [_mailComposer release];
    [_uuidCell release];
    [_nameCell release];
    [_systemCell release];
    [_modelCell release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)send:(id)sender
{
    if (_mailComposer == nil)
    {
        _mailComposer = [[MFMailComposeViewController alloc] init];
        _mailComposer.mailComposeDelegate = self;
    }

    NSString *messageTitle = NSLocalizedString(@"System information sent by DeviceDNA", @"Title of the e-mail message");
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"<p><strong>%@:</strong></p><ul>", messageTitle];
    
    if ([self exposesInformation:SystemInfoUUID])
    {
        NSString *uniqueIdentifierString = NSLocalizedString(@"Unique Device Identifier", @"The 'Unique Device Identifier' phrase");
        [body appendFormat:@"<li>%@ (UDID): <strong>%@</strong></li>", uniqueIdentifierString, _device.uniqueIdentifier];
    }
    if ([self exposesInformation:SystemInfoName])
    {
        NSString *nameString = NSLocalizedString(@"Device Name", @"The 'Name' word");
        [body appendFormat:@"<li>%@: <strong>%@</strong></li>", nameString, _device.name];
    }
    if ([self exposesInformation:SystemInfoOS])
    {
        NSString *iPhoneOSString = NSLocalizedString(@"iPhone OS Version", @"The 'iPhone OS' phrase");
        [body appendFormat:@"<li>%@: <strong>%@ %@</strong></li>", iPhoneOSString, _device.systemName, _device.systemVersion];
    }
    if ([self exposesInformation:SystemInfoModel])
    {
        NSString *modelString = NSLocalizedString(@"Device Model", @"The 'Model' word");
        [body appendFormat:@"<li>%@: <strong>%@</strong></li>", modelString, _device.localizedModel];        
    }
    NSString *allRightsReserved = NSLocalizedString(@"All Rights Reserved", @"The 'all rights reserved' phrase");
    [body appendFormat:@"</ul><p><strong>DeviceDNA</strong> © Copyright 2009 <a href=\"http://akosma.com/\">akosma software</a>. %@.</p>", allRightsReserved];
    
    [_mailComposer setToRecipients:[NSArray arrayWithObjects:@"devicedna@akosma.com", nil]];
    [_mailComposer setSubject:messageTitle];
    [_mailComposer setMessageBody:body isHTML:YES];

    [self presentModalViewController:_mailComposer animated:YES];
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
            cell = _uuidCell;
            break;
            
        case 1:
            cell = _nameCell;
            break;
            
        case 2:
            cell = _systemCell;
            break;
            
        case 3:
            cell = _modelCell;
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
    _exposedInfoMask ^= cell.tag;
    [self changeUIElements];
    
    // This makes a visual deselection after 1/10th of second
    [self performSelector:@selector(unselect) withObject:nil afterDelay:0.1];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
    [_mailComposer dismissModalViewControllerAnimated:YES];
    [_mailComposer release];
    _mailComposer = nil;
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    _tableView.rowHeight = 60;
    
    _device = [UIDevice currentDevice];
    _exposedInfoMask = SystemInfoUUID | SystemInfoName | SystemInfoOS | SystemInfoModel;
    NSString *identifier = @"SystemInformationCell";
    
    NSString *uniqueIdentifierString = NSLocalizedString(@"Unique Device Identifier", @"The 'Unique Device Identifier' phrase");
    NSString *nameString = NSLocalizedString(@"Device Name", @"The 'Name' word");
    NSString *iPhoneOSString = NSLocalizedString(@"iPhone OS Version", @"The 'iPhone OS' phrase");
    NSString *modelString = NSLocalizedString(@"Device Model", @"The 'Model' word");

    _uuidCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    _uuidCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _uuidCell.textLabel.text = _device.uniqueIdentifier;
    _uuidCell.detailTextLabel.text = uniqueIdentifierString;
    _uuidCell.tag = SystemInfoUUID;
    
    _nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    _nameCell.textLabel.text = _device.name;
    _nameCell.detailTextLabel.text = nameString;
    _nameCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _nameCell.tag = SystemInfoName;
    
    _systemCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    _systemCell.textLabel.text = [NSString stringWithFormat:@"%@ %@", _device.systemName, _device.systemVersion];
    _systemCell.detailTextLabel.text = iPhoneOSString;
    _systemCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _systemCell.tag = SystemInfoOS;
    
    _modelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    _modelCell.textLabel.text = _device.localizedModel;
    _modelCell.detailTextLabel.text = modelString;
    _modelCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _modelCell.tag = SystemInfoModel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self changeUIElements];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return NO;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Private methods

- (BOOL)exposesInformation:(SystemInfoItems)item
{
    return (_exposedInfoMask & item) == item;
}

- (void)changeUIElements
{
    BOOL uuidExposed = [self exposesInformation:SystemInfoUUID];
    BOOL nameExposed = [self exposesInformation:SystemInfoName];
    BOOL osExposed = [self exposesInformation:SystemInfoOS];
    BOOL modelExposed = [self exposesInformation:SystemInfoModel];
    
    _uuidCell.accessoryType = (uuidExposed) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _nameCell.accessoryType = (nameExposed) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _systemCell.accessoryType = (osExposed) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _modelCell.accessoryType = (modelExposed) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    _sendButton.enabled = (_exposedInfoMask != SystemInfoNone);
}

- (void)unselect
{
	// Unselect the selected row if any
    // http://forums.macrumors.com/showthread.php?t=577677
	NSIndexPath* selection = [_tableView indexPathForSelectedRow];
	if (selection)
    {
		[_tableView deselectRowAtIndexPath:selection animated:YES];
    }    
}

@end
