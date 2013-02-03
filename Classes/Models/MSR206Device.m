//
//  MSR505CMSRDevice.m
//  MagTool
//
//  Created by Kevin Brewster on 12/29/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "MSR206Device.h"

#define FIELD_SEPARATOR @"\x3F\x1C\x1B" // "[ESC][a][ESC][a]"

#define RESET_COMMAND @"\x1B\x61" // "[ESC][a][ESC][a]"
#define COMM_TEST_COMMAND @"\x1B\x65" // "[ESC][e]"
#define ALL_LED_OFF_COMMAND @"\x1B\x81"
#define ALL_LED_ON_COMMAND @"\x1B\x82"
#define SENSOR_TEST_COMMAND @"\x1B\x86"
#define RAM_TEST_COMMAND @"\x1B\x87"
#define SET_LEADING_ZEROS_COMMAND @"\x1B\x7A"
#define GET_LEADING_ZEROS_COMMAND @"\x1B\x6C"
#define ERASE_COMMAND @"\x1B\x63"
#define SET_BPI_COMMAND @"\x1B\x62" // Bits Per Inch
#define SET_BPC_COMMAND @"\x1B\x6F" // Bits Per Char
#define SET_HI_CO_COMMAND @"\x1B\x78" // Hi-Coercivity
#define SET_LO_CO_COMMAND @"\x1B\x79" // Low-Coercivity
#define GET_DEVICE_MODEL_COMMAND @"\x1B\x74"
#define GET_FIRMWARE_VERSION_COMMAND @"\x1B\x76"
#define GET_COERCIVITY_COMMAND @"\x1B\x64"
#define READ_ISO_COMMAND @"\x1B\x72" // "[ESC][r]"
#define WRITE_ISO_COMMAND @"\x1B\x77" // "[ESC][w]"
#define READ_RAW_COMMAND @"\x1B\x6D" // "[ESC][r]"
#define WRITE_RAW_COMMAND @"\x1B\x6E" // "[ESC][w]"


@implementation MSR206Device

@synthesize modelName = _modelName;
@synthesize firmwareVersion = _firmwareVersion;
@synthesize coercivity = _coercivity;
@synthesize BPI = _BPI;
@synthesize BPC = _BPC;
@synthesize leadingZero = _leadingZero;


- (id)initWithPort:(ORSSerialPort *)port
{
    if(self = [super init]){
        self.queue = [NSOperationQueue new];
        self.queue.maxConcurrentOperationCount = 1;
        
        self.port = port;
        self.port.baudRate = @9600;
       
        [self initDevice];
        [self.port open];
        
        self.availableBPC = @{@"1":@[@5,@6,@7,@8], @"2":@[@5,@6,@7,@8], @"3":@[@5,@6,@7,@8]};
        self.availableBPI = @{@"1":@[@210], @"2":@[@75,@210], @"3":@[@210]};
        
        NSMutableArray *zeros = [NSMutableArray array];
        for(int i=0; i<=140; i++) [zeros addObject:@(i)];
        self.availableLeadingZero = @{@"1":[NSArray arrayWithArray:zeros], @"2":[NSArray arrayWithArray:zeros], @"3":[NSArray arrayWithArray:zeros]};
        
        self.BPC = @{@"1":self.availableBPC[@"1"][0], @"2":self.availableBPC[@"2"][0], @"3":self.availableBPC[@"3"][0]};
        self.BPI = @{@"1":self.availableBPI[@"1"][0], @"2":self.availableBPI[@"2"][0], @"3":self.availableBPI[@"3"][0]};
    }
    return self;
}

- (void)sendCommand:(NSData *)command withStopString:(NSString *)stopString andStopBytes:(NSNumber *)stopBytes andCompletionBlock:(void (^)(NSData *data))block
{
    ORSSerialPortOperation *operation = [[ORSSerialPortOperation alloc] initWithPort:self.port andCommand:command andStopString:stopString andStopBytes:stopBytes andCompletionBlock:block];
    [self.queue addOperation:operation];
}
- (void)initDevice
{
    [self sendCommand:[RESET_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:nil andStopBytes:nil andCompletionBlock:nil];
    [self sendCommand:[COMM_TEST_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:nil andStopBytes:nil andCompletionBlock:nil];
    [self sendCommand:[RESET_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:nil andStopBytes:nil andCompletionBlock:nil];
}
- (void)resetDevice
{
    [self.queue cancelAllOperations];
    [self initDevice];
    [self.queue addOperationWithBlock:^{
        [self.port close];
        [self.port open];
    }];
}
- (void)cancelAction
{
    [self.queue cancelAllOperations];
    [self initDevice];
}

- (NSString *)modelName
{
    if(!_modelName){
        [self sendCommand:[GET_DEVICE_MODEL_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:nil andStopBytes:@3 andCompletionBlock:^(NSData *data) {
            NSString *modelNumber = [[NSString stringWithUTF8String:data.bytes] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\x1BS"]];
            
            [self willChangeValueForKey:@"modelName"];
            _modelName = [NSString stringWithFormat:@"MSR505C-%@", modelNumber];
            [self didChangeValueForKey:@"modelName"];
            
            [self willChangeValueForKey:@"availableTracks"];
            if(modelNumber.intValue == 1){
                self.availableTracks = @[@2];
            } else if(modelNumber.intValue == 2){
                self.availableTracks = @[@2, @3];
            } else if(modelNumber.intValue == 3){
                self.availableTracks = @[@1, @2, @3];
            } else if(modelNumber.intValue == 5){
                self.availableTracks = @[@1,@2];
            }
            [self didChangeValueForKey:@"availableTracks"];
        }];
    }
    return _modelName;
}
- (NSString *)firmwareVersion
{
    if(!_firmwareVersion){
        [self sendCommand:[GET_FIRMWARE_VERSION_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:nil andStopBytes:@9 andCompletionBlock:^(NSData *data) {
            [self willChangeValueForKey:@"firmwareVersion"];
            _firmwareVersion = [[NSString stringWithUTF8String:data.bytes] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\x1B"]];
            [self didChangeValueForKey:@"firmwareVersion"];
        }];
    }
    return _firmwareVersion;
}

- (void)setBPC:(NSDictionary *)BPC
{
    if(BPC[@"1"] && BPC[@"2"] && BPC[@"3"]){
        if(![BPC isEqualToDictionary:_BPC]){
            NSData *command = [NSData dataWithObjects:@[SET_BPC_COMMAND, BPC[@"1"], BPC[@"2"], BPC[@"3"]]];
            [self sendCommand:command withStopString:@"\x1B\x30" andStopBytes:@3 andCompletionBlock:^(NSData *response){
                // resonse = <ESC>30[tk1][tk2][tk3]
                const unsigned char *bytes = [response bytes];
                [self willChangeValueForKey:@"BPC"];
                _BPC = @{
                    @"1":[NSNumber numberWithInt:bytes[response.length-3]],
                    @"2":[NSNumber numberWithInt:bytes[response.length-2]],
                    @"3":[NSNumber numberWithInt:bytes[response.length-1]]
                };
                [self didChangeValueForKey:@"BPC"];
            }];
        }
    }
}
- (void)setBPI:(NSDictionary *)BPI
{
    if(BPI[@"2"]){
        NSData *command = [NSData dataWithObjects:@[SET_BPI_COMMAND, BPI[@"2"]]];
        [self sendCommand:command withStopString:nil andStopBytes:@2 andCompletionBlock:^(NSData *response){
            // resonse: <ESC>0 == OK, <ESC>A = FAIL
            if([response isEqualToData:[NSData dataWithBytes:"\x1b\x30" length:2]]){
                [self willChangeValueForKey:@"BPI"];
                _BPI = BPI;
                [self didChangeValueForKey:@"BPI"];
            } else{
                // NSLog(@"setBPI response: FAIL (%@)", response);
            }
            
        }];
    }
}


- (MagCoercivity)coercivity
{
    if(!_coercivity){
        [self sendCommand:[GET_COERCIVITY_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:@"\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response) {
            const unsigned char *bytes = response.bytes;
            [self willChangeValueForKey:@"coercivity"];
            if(bytes[response.length-1] == 104 || bytes[response.length-1] == 108){
                _coercivity = (bytes[response.length-1] == 104) ? MagHighCoercivity : MagLowCoercivity;
            } else{
                NSLog(@"Invalid response to getCoercivity: %@", response);
            }
            [self didChangeValueForKey:@"coercivity"];
        }];
    }
    return _coercivity;
}
- (void)setCoercivity:(MagCoercivity)coercivity
{
    NSString *command = (coercivity == MagHighCoercivity) ? SET_HI_CO_COMMAND : SET_LO_CO_COMMAND;
    [self sendCommand:[command dataUsingEncoding:NSUTF8StringEncoding] withStopString:@"\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response) {
        const unsigned char *bytes = response.bytes;
        [self willChangeValueForKey:@"coercivity"];
        if(bytes[response.length-1] == MagReadWriteOK){
            _coercivity = coercivity;
        } else{
            NSLog(@"Invalid response to setCoercivity: %@", response);
        }
        [self didChangeValueForKey:@"coercivity"];
    }];
}
- (NSDictionary *)leadingZero
{
    if(_leadingZero == nil){
        [self sendCommand:[GET_LEADING_ZEROS_COMMAND dataUsingEncoding:NSUTF8StringEncoding] withStopString:@"\x1B" andStopBytes:@2 andCompletionBlock:^(NSData *response) {
            NSLog(@"leadingZero response = %@", response);
            const unsigned char *bytes = response.bytes;
            
            /*
            _leadingZero[@"1"] = [NSNumber numberWithInt:bytes[response.length-2]];
            _leadingZero[@"2"] = [NSNumber numberWithInt:bytes[response.length-1]];
            _leadingZero[@"3"] = [NSNumber numberWithInt:bytes[response.length-2]];
           */
            
            [self willChangeValueForKey:@"leadingZero"];
            _leadingZero = @{
                @"1":[NSNumber numberWithInt:bytes[response.length-2]],
                @"2":[NSNumber numberWithInt:bytes[response.length-1]],
                @"3":[NSNumber numberWithInt:bytes[response.length-2]]
            };
            [self didChangeValueForKey:@"leadingZero"]; 
        }];
    }
    return _leadingZero;
}
- (void)setLeadingZero:(NSDictionary *)leadingZero
{
    NSNumber *track13LeadingZero = leadingZero[@"1"] ? [NSNumber numberWithInt:[leadingZero[@"1"] intValue]] : nil;
    NSNumber *track2LeadingZero = leadingZero[@"2"] ? [NSNumber numberWithInt:[leadingZero[@"2"] intValue]] : nil;
    
    if(track13LeadingZero && track2LeadingZero){
        leadingZero = @{@"1":track13LeadingZero, @"2":track2LeadingZero, @"3":track13LeadingZero};
        if(![leadingZero isEqualToDictionary:_leadingZero]){
            NSData *command = [NSData dataWithObjects:@[SET_LEADING_ZEROS_COMMAND, leadingZero[@"1"], leadingZero[@"2"]]];
            [self sendCommand:command withStopString:@"\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response) {
                const unsigned char *bytes = response.bytes;
                [self willChangeValueForKey:@"leadingZero"];
                if(bytes[response.length-1] == MagReadWriteOK){
                    _leadingZero = leadingZero;
                } else{
                    NSLog(@"Invalid response to setLeadingZero: %@", response);
                }
                [self didChangeValueForKey:@"leadingZero"];
            }];
        }
    } else{
        NSLog(@"Invalid arguments for setLeadingZero: %@", leadingZero);
    }
}



- (void)readTrackData:(NSString *)format withCompletionBlock:(void (^)(MSRStatus status, NSDictionary *tracks))block
{
    NSData *command = [NSData dataWithObjects:@[ [format isEqualToString:@"ISO"] ? READ_ISO_COMMAND : READ_RAW_COMMAND ]];
    [self sendCommand:command withStopString:@"\x3F\x1C\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response){
        const unsigned char *bytes = [response bytes];
        MSRStatus status = bytes[response.length-1];
        
        NSMutableDictionary *trackData = [NSMutableDictionary dictionary];
        
        if([format isEqualToString:@"ISO"]){
            // In ISO mode, we can simply look for the track delimitters and look for the data in between
            trackData[@"1"] = [response subdataBetweenStartBytes:"\x1B\x01" andEndBytes:"\x1B\x02"];
            trackData[@"2"] = [response subdataBetweenStartBytes:"\x1B\x02" andEndBytes:"\x1B\x03"];
            trackData[@"3"] = [response subdataBetweenStartBytes:"\x1B\x03" andEndBytes:"\x3F\x1C\x1B"];

        } else{
            // In Raw mode, we can't rely on track delimitters because the data might include them
            // Instead, we use the "track data size" byte that exists in Raw Mode
            // [1b01] [track1 length] [track1 data] [1b02] [track2 length] [track2 data] [1b03] [track3 length] [track3 data] [3f1c1b]
            
            BOOL decode = [format isEqualToString:@"Raw"];
            NSRange start = [response rangeOfData:[NSData dataWithBytes:"\x1B\x01" length:2] options:0 range:NSMakeRange(0,response.length)];
            NSRange range = NSMakeRange(start.location,0);
            
            for(NSString *key in @[@"1",@"2",@"3"]){
               range = NSMakeRange(range.location+range.length+3, bytes[range.location+range.length+2]);
                if(range.location != NSNotFound){
                    NSData *data = [response subdataWithRange:range];
                    if(decode) data = [self decodedData:data forTrack:@(key.intValue)];
                    trackData[key] = data;
                    
                }
            }
        }
        
        block(status, [NSDictionary dictionaryWithDictionary:trackData]);
    }];
}
- (void)writeTrackData:(NSDictionary *)trackData withFormat:(NSString *)format andCompletionBlock:(void (^)(MSRStatus status))block
{
     NSData *command = [NSData dataWithObjects:@[ [format isEqualToString:@"ISO"] ? WRITE_ISO_COMMAND : WRITE_RAW_COMMAND ]];

    if(![format isEqualToString:@"ISO"]){
        // for Raw data, we need to encode the data and prepend the size of the track data before each track
        NSMutableDictionary *encodedTrackData = [NSMutableDictionary dictionary];
        for(NSString *key in @[@"1",@"2",@"3"]){
            NSData *encodedData = trackData[key];
            if([format isEqualToString:@"Raw"]){
                // if the data has not already been encoded, do it now..
                encodedData = [self encodedData:encodedData forTrack:@(key.intValue)];
            }
            NSUInteger encodedDataSize = encodedData.length;
            NSMutableData *newData = [NSMutableData dataWithBytes:&encodedDataSize length:1];
            [newData appendData:encodedData];
            encodedTrackData[key] = newData;
        }
        trackData = [NSDictionary dictionaryWithDictionary:encodedTrackData];
    }

    // Assemble card data with 1b01, 1b02, 1b03 separators between tracks
    NSMutableData *cardData = [NSMutableData dataWithBytes:"\x1B\x01" length:2];
    [cardData appendData:trackData[@"1"]];
    [cardData appendBytes:"\x1B\x02" length:2];
    [cardData appendData:trackData[@"2"]];
    [cardData appendBytes:"\x1B\x03" length:2];
    [cardData appendData:trackData[@"3"]];
    
    // Assemble the whole data block to be sent: command + startBytes + cardData + endBytes
    NSMutableData *dataBlock = [NSMutableData dataWithData:command];
    [dataBlock appendBytes:"\x1B\x73" length:2];
    [dataBlock appendData:cardData];
    [dataBlock appendBytes:"\x3F\x1C" length:2];
    
    
    [self sendCommand:dataBlock withStopString:@"\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response){
        const unsigned char *bytes = [response bytes];
        MSRStatus status = bytes[response.length-1];
        block(status);
    }];
}

- (void)duplicateReadData:(NSDictionary *)trackData withCompletionBlock:(void (^)(MSRStatus status))block
{
    // reverse the bytes in the encoded data read from cards
    NSMutableDictionary *encodedTrackData = [NSMutableDictionary dictionary];
    for(NSString *key in @[@"1",@"2",@"3"]){
        NSData *data = trackData[key];
        if(data){
            encodedTrackData[key] = [[[data dataTrimmedOfStartingZeroBits] dataTrimmedOfZeros] dataWithBytesReversed];
        }
    }
    [self writeTrackData:encodedTrackData withFormat:@"Encoded" andCompletionBlock:block];
}


- (void)eraseTracks:(NSArray *)tracks withCompletionBlock:(void (^)(MSRStatus status))block
{
    if(tracks.count > 0){
        unsigned int selectByte = 0;
        if([tracks containsObject:@"1"] && ([tracks containsObject:@"2"] || [tracks containsObject:@"3"])) selectByte |= 1;
        if([tracks containsObject:@"2"]) selectByte |= 1<<1;
        if([tracks containsObject:@"3"]) selectByte |= 1<<2;
        
        NSMutableData *command = [[ERASE_COMMAND dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [command appendBytes:&selectByte length:1];

        [self sendCommand:command withStopString:@"\x1B" andStopBytes:@1 andCompletionBlock:^(NSData *response){
            const unsigned char *bytes = [response bytes];
            MSRStatus status = bytes[response.length-1];
            block(status);
        }];
    } else{
        block(0);
    }
}


- (NSData *)encodedData:(NSData *)data forTrack:(NSNumber *)track
{
    NSNumber *BPC = self.BPC[track];
    NSUInteger actualBPC;
    
    if(track.intValue == 1){
        actualBPC = 7;
    } else{
        actualBPC = 5;
    }
    
    BOOL useParity = (BPC.intValue != 6);
    BOOL usePadding = (BPC.intValue != 8);
    
    return [data encodedDataUsingBPC:actualBPC withParity:useParity andPadding:usePadding];
}
- (NSData *)decodedData:(NSData *)data forTrack:(NSNumber *)track
{
    NSNumber *BPC = self.BPC[track];
    NSUInteger actualBPC;
    
    if(track.intValue == 1){
        actualBPC = (BPC.intValue == 6) ? 6 : 7;
    } else{
        actualBPC = 5;
    }
    
    BOOL useParity = (BPC.intValue != 6);
    BOOL usePadding = (BPC.intValue != 8);
    
    return [data decodedDataUsingBPC:actualBPC withParity:useParity andPadding:usePadding];
}

@end
