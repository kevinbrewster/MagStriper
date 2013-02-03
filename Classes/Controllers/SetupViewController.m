//
//  SetupViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "SetupViewController.h"
#import "AppDelegate.h"

@interface SetupViewController ()
@property (weak) IBOutlet NSButton *resetDeviceButton;
@property (weak) IBOutlet NSPopUpButton *deviceSelect;

@end

@implementation SetupViewController

- (id)init
{
    return [super initWithNibName:@"SetupViewController" bundle:nil];
}

- (IBAction)resetDevice:(NSButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate.MSRDevice resetDevice];
}
- (IBAction)deviceSelected:(NSPopUpButton *)deviceSelect {
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    
    ORSSerialPort *port = [appDelegate.serialPortManager.availablePorts objectAtIndex:deviceSelect.indexOfSelectedItem];
    if(appDelegate.MSRDevice){
        appDelegate.MSRDevice.port = port;
        [appDelegate.MSRDevice modelName];
    }
}
@end
