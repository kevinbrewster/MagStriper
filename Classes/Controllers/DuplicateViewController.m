//
//  DuplicateViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 1/1/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import "DuplicateViewController.h"
#import "AppDelegate.h"

@interface DuplicateViewController ()

@end

@implementation DuplicateViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.actionButton.title = @"Duplicate";
    //[self.coercivitySelect setHidden:YES];
    [self.textFormatSelect setHidden:YES];
    [self.track1TextField setEnabled:NO];
    [self.track2TextField setEnabled:NO];
    [self.track3TextField setEnabled:NO];
}

- (void)doAction:(NSButton *)button
{
    // Readcard  data and display tracks
    if([button isEqualTo:self.actionButton]){
        [self duplicateCard];
    } else{
        [self verifyCard];
    }
}
- (void)duplicateCard
{
    self.trackString = nil;
    self.statusLabel.stringValue = @"Swipe original card..";
    
    if(self.trackData){
        self.statusLabel.stringValue = @"Swipe blank card..";
        [self.MSRDevice duplicateReadData:self.trackData withCompletionBlock:^(MSRStatus status) {
            [self endAction:self.actionButton withStatus:status];
            [self.actionButton2 setHidden:NO];
            self.actionButton2.title = @"Verify";
        }];
        return;
        
    }
    [self.MSRDevice readTrackData:@"Encoded" withCompletionBlock:^(MSRStatus status, NSDictionary *trackData) {
        if(status == MagReadWriteOK){
            self.trackData = trackData;
            self.trackString = [@{
                                @"1":[trackData[@"1"] hexadecimalString],
                                @"2":[trackData[@"2"] hexadecimalString],
                                @"3":[trackData[@"3"] hexadecimalString]
                                } mutableCopy];
            self.statusLabel.stringValue = @"Swipe blank card..";
            [self.MSRDevice duplicateReadData:trackData withCompletionBlock:^(MSRStatus status) {
                [self endAction:self.actionButton withStatus:status];
                [self.actionButton2 setHidden:NO];
                self.actionButton2.title = @"Verify";
            }];
        } else{
            [self endAction:self.actionButton withStatus:status];
        }
    }];
}
- (void)verifyCard
{
    self.statusLabel.stringValue = @"Re-swipe duplicate card..";
    
    [self.MSRDevice readTrackData:@"Encoded" withCompletionBlock:^(MSRStatus status, NSDictionary *trackData) {
        if(status == MagReadWriteOK){
            NSLog(@"Original Card Data = %@", self.trackData);
            
            NSLog(@"Duplicate Card Data = %@", trackData);
            
            
            if(![self.trackData isEqualToDictionary:trackData]){
                status = MagVerifyError;
            }
        }
        [self endAction:self.actionButton2 withStatus:status];
    }];
}
@end
