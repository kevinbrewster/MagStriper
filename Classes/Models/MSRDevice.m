//
//  MSRDevice.m
//  MagTool
//
//  Created by Kevin Brewster on 12/28/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "MSRDevice.h"


@interface MSRDevice ()

@end

@implementation MSRDevice

- (NSString *)statusDescription:(MSRStatus)status forAction:(NSString *)action
{
    NSString *statusDescription;
    
    switch (status) {
        case MagReadWriteOK:
            statusDescription = [NSString stringWithFormat:@"Successful %@.", action];
            break;
        case MagReadWriteError:
            statusDescription = [NSString stringWithFormat:@"Error during %@.", action];
            break;
        case MagInvalidFormat:
            statusDescription = @"Invalid format.";
            break;
        case MagInvalidSwipe:
            statusDescription = @"Invalid swipe.";
            break;
        case MagInvalidBPC:
            statusDescription = @"Invalid BPC.";
            break;
        case MagInvalidBPI:
            statusDescription = @"Invalid BPI.";
            break;
        case MagVerifyError:
            statusDescription = @"Verification Failed.";
            break;
        default:
            statusDescription = @"Uknown Error.";
            break;
    }
    return statusDescription;
}
@end
