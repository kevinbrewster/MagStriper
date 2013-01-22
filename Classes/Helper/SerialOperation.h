//
//  SerialOperation.h
//  MagTool
//
//  Created by Kevin Brewster on 12/31/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"


@interface SerialOperation : NSOperation <ORSSerialPortDelegate>

@property (strong,nonatomic) ORSSerialPort *port;
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) NSString *stopString;
@property (strong,nonatomic) NSNumber *stopBytes;
@property (assign) BOOL complete;

@end
