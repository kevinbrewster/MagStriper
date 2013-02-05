//
//  ReadWriteViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 12/30/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "ReadWriteViewController.h"


@interface ReadWriteViewController ()
@end

@implementation ReadWriteViewController

- (id)init {
    return [self initWithNibName:@"ReadWriteViewController" bundle:nil];
}
- (void)awakeFromNib
{
    self.dataFormatDefaults = @{
        @"ISO":@{@"1":@{@"BPC":@7,@"BPI":@210,@"leadingZero":@61}, @"2":@{@"BPC":@5,@"BPI":@75,@"leadingZero":@22}, @"3":@{@"BPC":@5,@"BPI":@210,@"leadingZero":@61} }
    };
    // set defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"BPI"]) self.MSRDevice.BPI = [defaults objectForKey:@"BPI"];
    if([defaults objectForKey:@"BPC"]) self.MSRDevice.BPC = [defaults objectForKey:@"BPC"];
    if([defaults objectForKey:@"leadingZero"]) self.MSRDevice.leadingZero = [defaults objectForKey:@"leadingZero"];
    
    self.selectedBPC = [self.MSRDevice.BPC mutableCopy];
    self.selectedBPI = [self.MSRDevice.BPI mutableCopy];
    self.selectedLeadingZero = [self.MSRDevice.leadingZero mutableCopy];
    self.dataFormat = [defaults objectForKey:@"dataFormat"];
    self.textFormat = [defaults objectForKey:@"textFormat"];
    
    for(NSString *key in @[@"BPI",@"BPC", @"leadingZero"]){
        [self.MSRDevice addObserver:self forKeyPath:key options:0 context:NULL];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"leadingZero"]){
        self.selectedLeadingZero = [self.MSRDevice.leadingZero mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedLeadingZero forKey:@"leadingZero"];
    } else if([keyPath isEqualToString:@"BPC"]){
        self.selectedBPC = [self.MSRDevice.BPC mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedBPC forKey:@"BPC"];
    } else if([keyPath isEqualToString:@"BPI"]){
        self.selectedBPI = [self.MSRDevice.BPI mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedBPI forKey:@"BPI"];
    }
}

- (void)setDataFormat:(NSString *)dataFormat
{
    _dataFormat = dataFormat;
    [[NSUserDefaults standardUserDefaults] setObject:dataFormat forKey:@"dataFormat"];
    NSDictionary *defaults = (self.dataFormatDefaults)[dataFormat];
    
    if(defaults){
        for(NSString *key in @[@"1",@"2",@"3"]){
            NSDictionary *defaultValues = defaults[key];
            self.selectedBPC[key] = defaultValues[@"BPC"];
            self.selectedBPI[key] = defaultValues[@"BPI"];
            self.selectedLeadingZero[key] = defaultValues[@"leadingZero"];
        }
    }
    self.MSRDevice.BPC = self.selectedBPC;
    self.MSRDevice.BPI = self.selectedBPI;
    self.MSRDevice.leadingZero = self.selectedLeadingZero;
}

- (void)setTextFormat:(NSString *)textFormat
{
    _textFormat = textFormat;
    [[NSUserDefaults standardUserDefaults] setObject:textFormat forKey:@"textFormat"];
}


#pragma mark IBActions





- (IBAction)settingsChanged:(id)sender
{
    self.dataFormat = @"Raw";
}

- (void)dealloc
{
    [self.MSRDevice removeObserver:self forKeyPath:@"BPI"];
    [self.MSRDevice removeObserver:self forKeyPath:@"BPC"];
    [self.MSRDevice removeObserver:self forKeyPath:@"leadingZero"];
}
@end
