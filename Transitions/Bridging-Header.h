//
//  Bridging-Header.h
//  Transitions
//
//  Created by Sebastian Wild on 10/5/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/i2c/IOI2CInterface.h>

typedef CFTypeRef IOAVService;
extern IOAVService IOAVServiceCreateWithService(CFAllocatorRef allocator, io_service_t service);

extern CFDictionaryRef CoreDisplay_DisplayCreateInfoDictionary(uint32_t CGDirectDisplayID);

extern IOReturn IOAVServiceReadI2C(IOAVService service, uint32_t chipAddress, uint32_t offset, void* outputBuffer, uint32_t outputBufferSize);
extern IOReturn IOAVServiceWriteI2C(IOAVService service, uint32_t chipAddress, uint32_t dataAddress, void* inputBuffer, uint32_t inputBufferSize);
