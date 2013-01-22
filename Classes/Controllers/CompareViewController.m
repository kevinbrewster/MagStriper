//
//  CompareViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 1/9/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import "CompareViewController.h"

@interface CompareViewController ()
@end

@implementation CompareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.cardATrackString = [NSMutableDictionary dictionary];
        self.cardBTrackString = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)doAction:(NSButton *)button
{
    self.cardATrackString = [NSDictionary dictionary];
    self.cardBTrackString = [NSDictionary dictionary];
    
    // Compare Cards
    self.statusLabel.stringValue = @"Swipe the fist card (A)..";
    [self.MSRDevice readTrackData:@"Encoded" withCompletionBlock:^(MSRStatus cardAStatus, NSDictionary *cardAData) {
        if(cardAStatus == MagReadWriteOK){
            self.cardATrackString = @{
                @"1": [cardAData[@"1"] hexadecimalString],
                @"2": [cardAData[@"2"] hexadecimalString],
                @"3": [cardAData[@"3"] hexadecimalString]
            };
            self.statusLabel.stringValue = @"Swipe the second card (B)..";
            [self.MSRDevice readTrackData:@"Encoded" withCompletionBlock:^(MSRStatus cardBStatus, NSDictionary *cardBData) {
                if(cardBStatus == MagReadWriteOK){
                    self.cardBTrackString = @{
                        @"1": [cardBData[@"1"] hexadecimalString],
                        @"2": [cardBData[@"2"] hexadecimalString],
                        @"3": [cardBData[@"3"] hexadecimalString]
                    };
                    if(![cardAData isEqualToDictionary:cardBData]){
                        cardBStatus = MagVerifyError;
                    }
                }
                [self endAction:self.actionButton withStatus:cardBStatus];
            }];
        } else{
            [self endAction:self.actionButton withStatus:cardAStatus];
        }
    }];
}

@end