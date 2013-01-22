//
//  NSData+MagStripeEncode.h
//  MagTool
//
//  Created by Kevin Brewster on 1/2/13.
//  Copyright (c) 2013 Kevin Brewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MagStripeEncode)

+ (NSData *)dataWithObjects:(NSArray *)objects;
+ (NSData *)dataFromHexString:(NSString *)string;
+ (NSData *)dataWithString:(NSString *)string usingBPC:(NSUInteger)BPC withParity:(BOOL)useParity andPadding:(BOOL)usePadding;
- (NSData *)encodedDataUsingBPC:(NSUInteger)BPC withParity:(BOOL)useParity andPadding:(BOOL)usePadding;
- (NSData *)decodedDataUsingBPC:(NSUInteger)BPC withParity:(BOOL)useParity andPadding:(BOOL)usePadding;
- (NSData *)dataWithBytesReversed;
- (NSData *)dataTrimmedOfStartingZeroBits;
- (NSData *)dataTrimmedOfZeros;
- (NSData *)subdataBetweenStartBytes: (const void *)startBytes andEndBytes:(const void *)endBytes;
- (NSString *)hexadecimalString;

@end
