//
//  SerialOperation.h
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
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


@interface ORSSerialPortOperation : NSOperation <ORSSerialPortDelegate>

@property (strong,nonatomic) ORSSerialPort *port;
@property (strong,nonatomic) NSData *command;
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) NSString *stopString;
@property (strong,nonatomic) NSNumber *stopBytes;
@property (assign) BOOL complete;

- (id)initWithPort:(ORSSerialPort *)port andCommand:(NSData *)command andStopString:(NSString *)stopString andStopBytes:(NSNumber *)stopBytes andCompletionBlock:(void (^)(NSData *data))block;

@end
