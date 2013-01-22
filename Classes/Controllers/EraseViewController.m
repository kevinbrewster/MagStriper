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
    }];
}

- (void)batchErase
{
    
    
}

@end
