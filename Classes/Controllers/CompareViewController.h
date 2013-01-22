//
//  CompareViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 1/9/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ActionViewController.h"

@interface CompareViewController : ActionViewController

@property (strong, nonatomic) NSDictionary *cardATrackString;
@property (strong, nonatomic) NSDictionary *cardBTrackString;

@end
