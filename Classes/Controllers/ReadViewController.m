//
//  ReadViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 12/30/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "ReadViewController.h"

@interface ReadViewController ()
@property (strong, nonatomic) CHCSVWriter *csvWriter;
@end

@implementation ReadViewController


- (void)awakeFromNib {
    [super awakeFromNib];
    self.actionButton.title = @"Read";
    [self.coercivitySelect setHidden:YES];
    [self.track1TextField setEditable:NO];
    [self.track2TextField setEditable:NO];
    [self.track3TextField setEditable:NO];
    
    [self.leadingZeroLabel setHidden:YES];
    [self.track1LeadingZeroSelect setHidden:YES];
    [self.track2LeadingZeroSelect setHidden:YES];
    [self.track3LeadingZeroSelect setHidden:YES];
}
- (void)setTextFormat:(NSString *)textFormat
{
    [super setTextFormat:textFormat];
    [self displayTrackData];
}
- (void)doAction:(NSButton *)button
{
    // Readcard  data and display tracks
    self.trackData = nil;
    self.trackString = nil;
    
    [self.MSRDevice readTrackData:self.dataFormat withCompletionBlock:^(MSRStatus status, NSDictionary *tracks) {
        [self endAction:self.actionButton withStatus:status];
        self.trackData = tracks;
        [self displayTrackData];
        
        if(self.csvWriter){
            [self.csvWriter writeLineOfFields:[tracks allValues]];
            [self actionButtonPressed:button];
        }
    }];
}

- (void)displayTrackData
{
    self.trackString = [NSMutableDictionary dictionary];
    for(NSString *key in @[@"1",@"2",@"3"]){
        NSData *data = self.trackData[key];
        if(data && data.length){
            if([self.textFormat isEqualToString:@"ASCII"]){
                self.trackString[key] = [NSString stringWithUTF8String:data.bytes];
            } else{
                self.trackString[key] = [data hexadecimalString];
            }
        }
    }
}

- (void)readToURL:(NSURL *)url withTrack:(NSNumber *)track
{
    if(self.pendingActionButton) [super cancelAction:self.pendingActionButton];
    
    self.dataFormat = @"ASCII";
    self.csvWriter = [[CHCSVWriter alloc] initForWritingToCSVFile:url.path];
    [self actionButtonPressed:self.actionButton];
}
- (void)cancelAction:(NSButton *)button
{
    [super cancelAction:button];
    self.csvWriter = nil;
}

@end
