//
//  ReadWriteViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 12/30/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
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
#import "ActionViewController.h"
#import "CHCSVParser.h"

@interface ReadWriteViewController : ActionViewController

// These are hooked up to UI elements with bindings
@property (strong,nonatomic) NSString *dataFormat; // ISO vs Raw
@property (strong,nonatomic) NSString *textFormat; // Hex vs ASCII
@property (strong,nonatomic) NSNumber *coercivity; // High [1] vs Low [0]

@property (strong,nonatomic) NSMutableDictionary *selectedBPC;
@property (strong,nonatomic) NSMutableDictionary *selectedBPI;
@property (strong,nonatomic) NSMutableDictionary *selectedLeadingZero;
@property (strong,nonatomic) NSDictionary *dataFormatDefaults;

@property (strong, nonatomic) NSDictionary *trackData;
@property (strong, nonatomic) NSMutableDictionary *trackString;

@property (weak) IBOutlet NSTextField *track1TextField;
@property (weak) IBOutlet NSTextField *track2TextField;
@property (weak) IBOutlet NSTextField *track3TextField;
@property (weak) IBOutlet NSSegmentedControl *coercivitySelect;
@property (weak) IBOutlet NSSegmentedControl *textFormatSelect;
@property (weak) IBOutlet NSComboBox *track1LeadingZeroSelect;
@property (weak) IBOutlet NSComboBox *track2LeadingZeroSelect;
@property (weak) IBOutlet NSComboBox *track3LeadingZeroSelect;
@property (weak) IBOutlet NSTextField *leadingZeroLabel;


@end
