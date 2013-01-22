//
//  SerialOperation.m
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "ORSSerialPortOperation.h"

#define RESET_COMMAND @"\x1B\x61" // "[ESC][a][ESC][a]"
#define READ_ISO_COMMAND @"\x1B\x72" // "[ESC][r]"
#define WRITE_ISO_COMMAND @"\x1B\x77" // "[ESC][w]"
#define READ_RAW_COMMAND @"\x1B\x6D" // "[ESC][r]"
#define WRITE_RAW_COMMAND @"\x1B\x6E" // "[ESC][w]"
#define COMM_TEST_COMMAND @"\x1B\x65" // "[ESC][e]"

//#define LOG_SERIAL_PORT_NOTICES 1

#ifdef LOG_SERIAL_PORT_NOTICES
#define LOG_SERIAL_PORT_NOTICE(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define LOG_SERIAL_PORT_NOTICE(fmt, ...)
#endif


@implementation ORSSerialPortOperation

- (id)initWithPort:(ORSSerialPort *)port andCommand:(NSData *)command andStopString:(NSString *)stopString andStopBytes:(NSNumber *)stopBytes andCompletionBlock:(void (^)(NSData *data))block
{
    if(self = [super init]){
        LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: init", command);
        self.command = command;
        self.port = port;
        self.receivedData = [NSMutableData data];
        self.stopBytes = stopBytes;
        self.stopString = stopString;
        objc_setAssociatedObject(self, "blockCallback", [block copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return self;
}
- (void)main
{
    LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: main, isOpen = %d", self.command, self.port.isOpen);
    self.port.delegate = self;
    if(self.port.isOpen) [self serialPortWasOpened:nil]; // run the command
    
    while(!self.complete && !self.isCancelled){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    self.port.delegate = nil;
}
- (void)finishOperation
{
    LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: finishOperation", self.command);
    
    self.port.delegate = nil;
    [self willChangeValueForKey:@"isFinished"];
    self.complete = YES;
    
    
    if(!self.isCancelled){
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            void (^block)(NSData *data) = objc_getAssociatedObject(self, "blockCallback");
            if(block) block(self.receivedData);
        }];
    }
    [self didChangeValueForKey:@"isFinished"];
}
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: didReceiveData: %@, stopBytes = %@", self.command, data, self.stopBytes);
    
    if(self.isCancelled || self.complete)
        return;
    
    [self.receivedData appendData:data];
    
    if(!self.stopBytes) self.stopBytes = @0;
    NSUInteger receivedDataLength = self.receivedData.length;
    
    if (self.stopString) {
        NSData *stopData = [self.stopString dataUsingEncoding:NSUTF8StringEncoding];
        NSRange range = [self.receivedData rangeOfData:stopData options:0 range:NSMakeRange(0,self.receivedData.length)];
        if(range.location != NSNotFound){
            receivedDataLength = self.receivedData.length - range.location - range.length;
        } else{
            return;
        }
    }
    if (receivedDataLength >= self.stopBytes.intValue) {
        [self finishOperation];
    }
}
- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	LOG_SERIAL_PORT_NOTICE(@"Serial port %@ encountered an error: %@", serialPort, error);
    [self cancel];
}
- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    if(serialPort){
        LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: Serial port %@ was opened", self.command, serialPort);
    }
    [self.port sendData:self.command];
    
    if(!self.stopString && !self.stopBytes){
        //[NSThread sleepForTimeInterval:.1];
        return [self finishOperation];
    }
}
- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: Serial port %@ was closed", self.command, serialPort);
    [self cancel];
}
- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    LOG_SERIAL_PORT_NOTICE(@"ORSSerialPortOperation %@: Serial port %@ ewas removed from system", self.command, serialPort);
    [self cancel];
}

@end
