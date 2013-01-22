//
//  ReadWriteViewController.h
//  MagTool
//
//  Created by Kevin Brewster on 12/30/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

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
