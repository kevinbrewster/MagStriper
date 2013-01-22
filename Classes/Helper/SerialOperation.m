//
//  SerialOperation.m
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "SerialOperation.h"

#define RESET_COMMAND @"\x1B\x61" // "[ESC][a][ESC][a]"
#define READ_ISO_COMMAND @"\x1B\x72" // "[ESC][r]"
#define WRITE_ISO_COMMAND @"\x1B\x77" // "[ESC][w]"
#define READ_RAW_COMMAND @"\x1B\x6D" // "[ESC][r]"
#define WRITE_RAW_COMMAND @"\x1B\x6E" // "[ESC][w]"
#define COMM_TEST_COMMAND @"\x1B\x65" // "[ESC][e]"


@implementation SerialOperation

- (id)initWithPort:(ORSSerialPort *)port andCommand:(NSString *)command andStopString:(NSString *)stopString andStopBytes:(NSNumber *)stopBytes andCompletionBlock:(void (^)(NSData *data))block
{
    if(self = [super init]){
        self.port = port;
        self.port.delegate = self;
        self.receivedData = [NSMutableData data];
        self.stopBytes = stopBytes;
        self.stopString = stopString;
        objc_setAssociatedObject(self, "blockCallback", [block copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.port sendData:[command dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}
- (BOOL)isFinished
{
    return self.complete;
}
- (void)finishOperation
{
    [self willChangeValueForKey:@"isFinished"];
    self.complete = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    void (^block)(NSData *data) = objc_getAssociatedObject(self, "blockCallback");
    block(self.receivedData);
}
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    if(self.isCancelled){
        self.complete = YES;
        return;
    }
    
    [self.receivedData appendData:data];
    
    if(!self.stopBytes) self.stopBytes = @0;
    NSUInteger receivedDataLength = self.receivedData.length;
    
    if (self.stopString) {
        NSData *stopData = [self.stopString dataUsingEncoding:NSUTF8StringEncoding];
        NSRange range = [self.receivedData rangeOfData:stopData options:0 range:NSMakeRange(0,self.receivedData.length)];
        if(range.location != NSNotFound){
            receivedDataLength = self.receivedData.length - range.location - range.length;
        }
    }
    if (receivedDataLength >= self.stopBytes.intValue) {
        self.complete = YES;
    }
}
- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	//NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}
- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
   // NSLog(@"Serial port %@ was opened", serialPort);
    
}
- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    //NSLog(@"Serial port %@ was closed", serialPort);
}
- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
   // NSLog(@"Serial port %@ ewas removed from system", serialPort);
}

@end
