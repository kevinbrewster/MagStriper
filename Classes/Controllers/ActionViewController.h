//
//  ActionViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 1/9/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSRDevice.h"
#import "AppDelegate.h"

@interface ActionViewController : NSViewController

@property (strong,nonatomic) MSRDevice *MSRDevice;
@property (strong,nonatomic) NSButton *pendingActionButton;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSProgressIndicator *activityProgressIndicator;
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSButton *actionButton2;


- (void)beginAction:(NSButton *)button;
- (void)endAction:(NSButton *)button;
- (void)endAction:(NSButton *)button withStatus:(MSRStatus)status;
- (void)cancelAction:(NSButton *)button;
- (IBAction)actionButtonPressed:(NSButton *)button;

@end
