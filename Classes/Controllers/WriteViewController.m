//
//  WriteViewController.m
//  MagTool
//
//  Created by Kevin Brewster on 12/30/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "WriteViewController.h"

@interface WriteViewController ()
@property (strong,nonatomic) NSMutableArray *writeQueue;
@property (assign) NSUInteger completedWrites;
@end

@implementation WriteViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.actionButton.title = @"Write";
    
    self.trackString = [NSMutableDictionary dictionary];
    
    //MSRDevice = 2;
    
    //[self writeFromURL:@"file://localhost/Users/kevinbrewster/Desktop/good%20codes.txt" withTrack:nil];
    //[self writeFromURL:[NSURL URLWithString:@"file://localhost/Users/kevinbrewster/Desktop/good%20codes.txt"] withTrack:nil];
    //[self writeFromURL:[NSURL URLWithString:@"file://localhost/Users/kevinbrewster/Desktop/GoodCodes.csv"] withTrack:nil];
}

- (void)doAction:(NSButton *)button
{
    // Write Card

    if(self.writeQueue.count){
        self.trackString = [self.writeQueue objectAtIndex:0];
        self.statusLabel.stringValue = [NSString stringWithFormat:@"Swipe card %ld / %ld", self.completedWrites+1, self.completedWrites+self.writeQueue.count];
    }

    NSMutableDictionary *trackData = [NSMutableDictionary dictionary];
    for(NSString *key in @[@"1",@"2",@"3"]){
        NSString *string = self.trackString[key];
        if(string.length){
            NSData *data;
            if([self.textFormat isEqualToString:@"ASCII"]){
                if([self.dataFormat isEqualToString:@"ISO"]){
                    NSCharacterSet *sentinelChars = [NSCharacterSet characterSetWithCharactersInString:@";?"];
                    string = [string stringByTrimmingCharactersInSet:sentinelChars];
                }
                data = [NSData dataWithBytes:string.UTF8String length:string.length];
            } else{
                data = [NSData dataFromHexString:string];
            }
            if(data) trackData[key] = data;
        }
    }
    [self.MSRDevice writeTrackData:[NSDictionary dictionaryWithDictionary:trackData] withFormat:self.dataFormat andCompletionBlock:^(MSRStatus status) {
        [self endAction:self.actionButton withStatus:status];
        
        if(self.writeQueue.count){
            self.completedWrites++;
            [self.writeQueue removeObjectAtIndex:0];
            if(self.writeQueue.count){
                [self actionButtonPressed:button];
            }
        }
    }];
}
- (void)cancelAction:(NSButton *)button
{
    if(button && self.writeQueue.count > 1){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Cancel All Remaining Writes"];
        [alert addButtonWithTitle:@"Cancel Single Write"];
        [alert setMessageText:[NSString stringWithFormat:@"Cancel the remaining %ld writes?", self.writeQueue.count]];
        //[alert setInformativeText:@"Deleted records cannot be restored."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        [alert beginSheetModalForWindow:appDelegate.window
                              modalDelegate:self
                             didEndSelector:@selector(cancelAlertDidEnd:returnCode:contextInfo:)
                                contextInfo:nil];
    } else{
        self.writeQueue = nil;
        [super cancelAction:button];
    }
}
- (void)cancelAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == NSAlertFirstButtonReturn){
        // cancel all writes
        self.writeQueue = nil;
        [super cancelAction:self.actionButton];
    } else{
        // cancel single write
        [self.writeQueue removeObjectAtIndex:0];
        [super cancelAction:self.actionButton];
        [super actionButtonPressed:self.actionButton];
    }
}

- (void)writeFromURL:(NSURL *)url withTrack:(NSNumber *)track
{
    if(self.pendingActionButton) [super cancelAction:self.pendingActionButton];
    
    NSString *errorMessage;
    
    self.writeQueue = [NSMutableArray array];
    self.completedWrites = 0;
    
    NSArray *csvRows = [NSArray arrayWithContentsOfCSVFile:url.path];
    if(csvRows){
        for(NSArray *row in csvRows){
            NSMutableDictionary *trackString = [NSMutableDictionary dictionary];
            if(track){
                if(row.count > 0) trackString[track.stringValue] = row[0];
            } else{
                if(row.count > 0) trackString[@"1"] = row[0];
                if(row.count > 1) trackString[@"2"] = row[1];
                if(row.count > 2) trackString[@"3"] = row[2];
            }
            if(trackString.count) [self.writeQueue addObject:trackString];
        }
        if(self.writeQueue.count){
            self.textFormat = @"ASCII";
            [self actionButtonPressed:self.actionButton];
        } else{
            errorMessage = @"No track data found in file.";
        }
    } else{
        errorMessage = @"Error parsing file.";
    }

    if(errorMessage){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:errorMessage];
        [alert setAlertStyle:NSWarningAlertStyle];
        AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        [alert beginSheetModalForWindow:appDelegate.window
                          modalDelegate:self
                         didEndSelector:nil
                            contextInfo:nil];
    }
}

@end
