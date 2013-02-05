//
//  DeleteViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 1/1/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import "EraseViewController.h"
#import "AppDelegate.h"

@interface EraseViewController ()
@property (assign) BOOL batch;
@property (assign) NSUInteger batchErased;
@end

@implementation EraseViewController


- (id)init
{
    if(self = [super initWithNibName:@"EraseViewController" bundle:nil]){
        self.tracks = [@{@"1":@1, @"2":@2, @"3":@3} mutableCopy];
    }
    return self;
}
- (void)doAction:(NSButton *)button
{
    // Erase Card
    NSMutableArray *tracks = [NSMutableArray array];
    for(NSString *key in @[@"1",@"2",@"3"]){
        if(self.tracks[key] && [self.tracks[key] intValue]){
            [tracks addObject:key];
        }
    }
    [self.MSRDevice eraseTracks:tracks withCompletionBlock:^(MSRStatus status) {
        [self endAction:self.actionButton withStatus:status];
        if(status == MagReadWriteOK) self.batchErased++;
        if(self.batch){
            [self actionButtonPressed:button];
            self.statusLabel.stringValue = [NSString stringWithFormat:@"Erased %ld. Swipe next card..", self.batchErased];
            self.actionButton.title = @"Done";
        }
    }];
}

- (void)batchErase
{
    self.batch = YES;
    self.batchErased = 0;
    [self actionButtonPressed:self.actionButton];
    self.actionButton.title = @"Done";
}
- (void)cancelAction:(NSButton *)button
{
    [super cancelAction:button];
    self.batch = NO;
}

@end
