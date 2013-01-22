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

@end

@implementation SetupViewController

- (id)init
{
    return [super initWithNibName:@"SetupViewController" bundle:nil];
}

- (void)awakeFromNib
{
    NSLog(@"awakefromniub");
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];

    NSLog(@"%@", appDelegate.serialPortManager.availablePorts);
}
- (IBAction)resetDevice:(NSButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate.MSRDevice resetDevice];
}
@end
