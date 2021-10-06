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

extern CFDictionaryRef CoreDisplay_DisplayCreateInfoDictionary(CGDirectDisplayID);
