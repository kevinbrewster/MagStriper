//
//  ActionViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 1/9/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import "ActionViewController.h"

@interface ActionViewController ()

@end

@implementation ActionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (MSRDevice *)MSRDevice
{
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    return appDelegate.MSRDevice;
}

- (void)beginAction:(NSButton *)button
{
    [self.statusLabel setHidden:NO];
    self.statusLabel.stringValue = @"Swipe card..";
    self.pendingActionButton = button;
    [self.activityProgressIndicator setHidden:NO];
    [self.activityProgressIndicator startAnimation:self];
    button.identifier = button.title;
    button.title = @"Cancel";
}
- (void)endAction:(NSButton *)button
{
    [self.statusLabel setHidden:YES];
    [self.activityProgressIndicator setHidden:YES];
    [self.activityProgressIndicator stopAnimation:self];
    button.title = button.identifier;
    self.pendingActionButton = nil;
}
- (void)endAction:(NSButton *)button withStatus:(MSRStatus)status
{
    NSString *action = button.identifier;
    [self endAction:button];
    self.statusLabel.stringValue = [self.MSRDevice statusDescription:status forAction:action];
    [self.statusLabel setHidden:NO];
}
- (void)cancelAction:(NSButton *)button
{
    if(!button) button = self.pendingActionButton;
    if(button){
        [self endAction:button];
        self.actionButton.identifier = self.actionButton.stringValue;
        [self.MSRDevice cancelAction];
    }
}
- (IBAction)actionButtonPressed:(NSButton *)button
{
    if(self.pendingActionButton){
        [self cancelAction:button];
    } else{
        [self beginAction:button];
        if([self respondsToSelector:@selector(doAction:)]){
            [self performSelector:@selector(doAction:) withObject:button];
        }
    }
}

@end
