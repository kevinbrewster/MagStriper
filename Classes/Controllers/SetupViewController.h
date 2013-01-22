//
//  SetupViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSRDevice.h"

@interface SetupViewController : NSViewController

@property (strong, nonatomic) MSRDevice *selectedMSRDevice;

@end
