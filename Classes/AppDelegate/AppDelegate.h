//
//  AppDelegate.h
//  MagTool
//
//  Created by Kevin Brewster on 12/28/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSRDevice.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTabView *tabView;

@property (strong, nonatomic) ORSSerialPortManager *serialPortManager;
@property (strong, nonatomic) MSRDevice *MSRDevice;
@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSPopUpButton *fileOptionsSelect;


@end
