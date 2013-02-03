//
//  NSData+MagStripeEncode.m
//  MagTool
//
//  Created by Kevin Brewster on 1/2/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import "NSData+MagStripeEncode.h"

@implementation NSData (MagStripeEncode)



+ (NSData *)dataWithObjects:(NSArray *)objects
{
    NSMutableData *data = [NSMutableData data];
    for(id object in objects){
        if ([object isKindOfClass:[NSString class]]){
            [data appendData:[object dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([object isKindOfClass:[NSNumber class]]){
            NSUInteger intVal = [object intValue];
            [data appendBytes:&intVal length:1];
        }
    }
    return [NSData dataWithData:data];
}
+ (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    NSUInteger length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        
    }
    
    return data;
}
- (NSData *)subdataBetweenStartBytes: (const void *)startBytes andEndBytes:(const void *)endBytes
{
    NSRange startRange = [self rangeOfData:[NSData dataWithBytes:startBytes length:strlen(startBytes)] options:0 range:NSMakeRange(0,self.length)];
    if(startRange.location != NSNotFound) {
        NSRange endRange = [self rangeOfData:[NSData dataWithBytes:endBytes length:strlen(endBytes)] options:0 range:NSMakeRange(0,self.length)];
        if(endRange.location != NSNotFound) {
            return [self subdataWithRange:NSMakeRange(startRange.location+startRange.length, endRange.location-startRange.location-startRange.length)];
        }
    }
    return nil;
}

- (NSString *)hexadecimalString
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

- (NSData *)dataTrimmedOfStartingZeroBits
{
    if(!self.length) return self;
    
    NSMutableData *newData = [NSMutableData data];
    
    const unsigned char *bytes = self.bytes;
    unsigned int bitShift = 0;
    for(int i=7; i>0; i--){
        if(bytes[0] < pow(2,i)) bitShift++;
    }
    for(int i=0; i<self.length; i++){
        unsigned char byte = bytes[i];
        byte = byte << bitShift;
        
        if(i+1 < self.length){
            byte = byte | (bytes[i+1] >> (8-bitShift));
        }
        [newData appendBytes:&byte length:1];
    }
    return [NSData dataWithData:newData];
}
- (NSData *)dataTrimmedOfZeros
{
    if(!self.length) return self;
    
    NSMutableData *data = self.mutableCopy;
    // remove any trailing 00's from data
    NSRange range = [data rangeOfData:[NSData dataWithBytes:"\x00" length:1] options:0 range:NSMakeRange(0, data.length)];
    if(range.location != NSNotFound){
        [data setLength:range.location];
    }
    return [NSData dataWithData:data];
}
- (NSData *)dataWithBytesReversed
{
    if(!self.length) return self;
    
    NSUInteger dataLength = self.length;
    
    const unsigned char *bytes = self.bytes;
    unsigned char LRC = 0;
    NSMutableData *newData = [NSMutableData dataWithLength:dataLength];
    unsigned char *newBytes = newData.mutableBytes;
    
    for(int j=0; j<dataLength; j++){
        newBytes[j] = reverseByte(bytes[j]);
        LRC = LRC ^ newBytes[j];
    }
    LRC = ~LRC;
    LRC = LRC << 1;
    
    return [NSData dataWithData:newData];
}

- (NSData *)decodedDataUsingBPC:(NSUInteger)BPC withParity:(BOOL)useParity andPadding:(BOOL)usePadding
{
    NSMutableData *newData = [NSMutableData data];
    unsigned char chunkSize = usePadding ? 8 : BPC;
    
    NSData *data = [self dataTrimmedOfZeros];
    if(!data.length) return newData;
    
    const unsigned char *bytes = data.bytes;
    int ascii_offset = 32;
    
    if(BPC == 6) ascii_offset = 32;
    if(BPC == 5) ascii_offset = 48;
    
    NSUInteger newLength = ((data.length*8)-chunkSize) / chunkSize;
    
    
    int bitOffsetMain = 0;
    for(int i=7; i>0; i--){
        if(bytes[0] < pow(2,i)) bitOffsetMain++;
    }
     
    for(int i=0; i<newLength; i++){
        int bytePos = i*chunkSize/8;
        int bitOffset = bitOffsetMain + (i*chunkSize % 8);
        
        unsigned char byte = bytes[bytePos];

        byte = byte << bitOffset;
        if(bitOffset + BPC >= 8 && bytePos+1 < data.length){
            unsigned char nextByte = bytes[bytePos+1];
            byte = byte | (nextByte >> (8-bitOffset));
        }
        if(chunkSize < 8) byte = byte >> (8 - chunkSize);
        
        byte = reverseByte(byte);
    
        if(useParity) byte = byte & ~(1 << BPC+(7-chunkSize));  // chunk = 8
        
        if(chunkSize < 8) byte = byte >> (8-BPC);
      
        byte += ascii_offset;
        
        if(BPC == 5 && !useParity && usePadding && byte > 60){
            // special case for ? in tracks 2/3 using 5 BPC and no parity
            byte -= 16;
        }
        
        [newData appendBytes:&byte length:1];
    }
    return [NSData dataWithData:newData];
}

- (NSData *)encodedDataUsingBPC:(NSUInteger)BPC withParity:(BOOL)useParity andPadding:(BOOL)usePadding
{
    NSUInteger padding = (usePadding) ? 8 - BPC : 0;
    
    const char *bytes = self.bytes;
    NSUInteger newLength = ((self.length*(BPC+padding))+BPC+padding+7) / 8;
    
    NSMutableData* data = [NSMutableData dataWithLength:newLength];
    unsigned char *newBytes = [data mutableBytes];
    //unsigned char LRC_bits[BPC];
    unsigned char *LRC_bits = malloc(sizeof(int) * BPC);
    
    int bitOffset = 0;
    int byteCount = 0;

    NSUInteger ascii_offset = (11-BPC)*8;
    ascii_offset=48;
    
    if(BPC == 7) ascii_offset = 32;
    if(BPC == 5) ascii_offset = 48;
    
    for(int i=0; i<self.length; i++){
        unsigned char c = (bytes[i] < ascii_offset) ? bytes[i]%16 : bytes[i] - ascii_offset;
        
        if(BPC == 5 && !useParity && usePadding && bytes[i] > 60){
            // special case for ? in tracks 2/3 using 5 BPC and no parity
            c += 16;
        }
        
        c = reverseByte(c);
        
        for(int j=0; j<BPC; j++){
            if(i == 0) LRC_bits[j] = 0;
            LRC_bits[j] = LRC_bits[j] ^ (c & 1<<(7-j));
        }
        
        if(useParity){
            bool parity = (((c * 0x0101010101010101ULL) & 0x8040201008040201ULL) % 0x1FF) & 1;
            if(!parity) c = c | 1<<(8-BPC);
        }
         
        unsigned char prev = newBytes[byteCount];
        newBytes[byteCount] = prev | (c >> bitOffset);
        bitOffset += BPC+padding;
        
        if(bitOffset >= 8){
            byteCount++;
            bitOffset -= 8;
            
            if(bitOffset){
                newBytes[byteCount] = c << (BPC-bitOffset);
                
            }
        }
    }
    
    // LRC
    unsigned char LRC = 0;
    for(int j=0; j<BPC; j++){
        LRC = LRC | LRC_bits[j];
    }
    if(useParity){
        bool LRC_parity = (((LRC * 0x0101010101010101ULL) & 0x8040201008040201ULL) % 0x1FF) & 1;
        if(!LRC_parity) LRC = LRC | 1<<(8-BPC);
    }
    
    if(bitOffset){
        unsigned char prev = newBytes[byteCount];
        newBytes[byteCount] = prev | (LRC >> bitOffset);
        bitOffset = 8-bitOffset;
        byteCount++;
    }
    newBytes[byteCount] = LRC << bitOffset;
   
    for(int j=0; j<newLength; j++){
        newBytes[j] = reverseByte(newBytes[j]);
    }
    
    return [NSData dataWithData:data];
}



unsigned char reverseByte(unsigned char b) {
    b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
    b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
    b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
    return b;
}


@end
