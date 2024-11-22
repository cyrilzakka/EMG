//
//  readers.m
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

#import <Foundation/Foundation.h>
#import "ioreport.h"

NSDictionary*appleSiliconSensors(int32_t page, int32_t usage, int32_t type) {
    NSDictionary* dictionary = @{@"PrimaryUsagePage":@(page),@"PrimaryUsage":@(usage)};
    
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, (__bridge CFDictionaryRef)dictionary);
    CFArrayRef services = IOHIDEventSystemClientCopyServices(system);
    if (services == nil) {
        return nil;
    }
    
    NSMutableDictionary*dict = [NSMutableDictionary dictionary];
    for (int i = 0; i < CFArrayGetCount(services); i++) {
        IOHIDServiceClientRef service = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(services, i);
        NSString* name = CFBridgingRelease(IOHIDServiceClientCopyProperty(service, CFSTR("Product")));
        
        IOHIDEventRef event = IOHIDServiceClientCopyEvent(service, type, 0, 0);
        if (event == nil) {
            continue;
        }
        
        if (name && event) {
            double value = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(type));
            dict[name]=@(value);
        }
        
        CFRelease(event);
    }
    
    CFRelease(services);
    CFRelease(system);
    
    return dict;
}
