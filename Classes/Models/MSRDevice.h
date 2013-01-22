//
//  MSRDevice.h
//  MagTool
//
//  Created by Kevin Brewster on 12/28/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
