//
//  MSRDevice.h
//  MagTool
//
//  Created by Kevin Brewster on 12/28/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialPortOperation.h"
#import "NSData+MagStripeEncode.h"


typedef NS_ENUM(NSInteger, MSRStatus) {
    MagReadWriteOK = 48,
    MagReadWriteError = 49,
    MagInvalidFormat = 50,
    MagInvalidCommand = 52,
    MagInvalidSwipe = 57,
    MagInvalidBPC = 58,
    MagInvalidBPI = 59,
    MagVerifyError = 60
};

typedef NS_ENUM(NSInteger, MagCoercivity) {
    MagHighCoercivity = 1,
    MagLowCoercivity = 2
};

@interface MSRDevice : NSObject

@property (strong,nonatomic) ORSSerialPort *port;
@property (strong, nonatomic) NSOperationQueue *queue; // commands sent to device are queued up here
@property (strong, nonatomic) NSString *modelName; // e.g. "MSR505-c"
@property (strong, nonatomic) NSString *firmwareVersion; // e.g. "REVU1.05"
@property (assign, nonatomic) MagCoercivity coercivity;
@property (strong, nonatomic) NSArray *availableTracks; // tracks capable of being read/written to, e.g. [1,2,3];
@property (strong, nonatomic) NSDictionary *availableBPC; // the BPC available for each track, e.g. {"1": [5,6,7,8], "2": [5,6]}
@property (strong, nonatomic) NSDictionary *availableBPI; // the BPC available for each track, e.g. {"1": [210], "2": [75.210]}
@property (strong, nonatomic) NSDictionary *availableLeadingZero; // the leading zeros available for each track, e.g. {"1": [1,2,3,4,..], "2": [1,2,3,4,..]}

@property (strong, nonatomic) NSDictionary *leadingZero;
@property (strong, nonatomic) NSDictionary *BPC; // the BPC currently set, e.g. {"1": 5, "2": 6, "3":8}
@property (strong, nonatomic) NSDictionary *BPI; // the BPC currently set, e.g. {"1": 210, "2": 75, "3": 210}
@property (strong, nonatomic) NSDictionary *encodedTrackData; // the encoded data read from device, e.g. {"1": <a2f5e1>, "2": <a2f5e1>}

- (NSString *)statusDescription:(MSRStatus)status forAction:(NSString *)action;
- (id)initWithPort:(ORSSerialPort *)port;
- (void)resetDevice;
- (void)initDevice;
- (void)cancelAction;
- (void)readTrackData:(NSString *)format withCompletionBlock:(void (^)(MSRStatus status, NSDictionary *tracks))block;
- (void)writeTrackData:(NSDictionary *)tracks withFormat:(NSString *)format andCompletionBlock:(void (^)(MSRStatus status))block;
- (void)duplicateReadData:(NSDictionary *)trackData withCompletionBlock:(void (^)(MSRStatus status))block;
- (void)eraseTracks:(NSArray *)tracks withCompletionBlock:(void (^)(MSRStatus status))block;
//- (NSData *)encodedData:(NSData *)data forTrack:(NSNumber *)track;
//- (NSData *)decodedData:(NSData *)data forTrack:(NSNumber *)track;

@end
