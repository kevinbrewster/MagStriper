//
//  ActionViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 1/9/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
