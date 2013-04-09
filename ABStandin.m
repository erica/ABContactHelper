//
//  AddressBook.m
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import "ABStandin.h"

static ABAddressBookRef shared = NULL;

@implementation ABStandin
// Return the current shared address book, 
// Creating if needed
+ (ABAddressBookRef) addressBook
{
    @synchronized (self) {
        if (!shared) {
            if (ABAddressBookCreateWithOptions == NULL) {
                shared = ABAddressBookCreate();
            } else {
                shared = ABAddressBookCreateWithOptions(NULL, NULL);
            }
            if (![self hasAddressBookAccess:shared]) {
                //TODO: show beautiful alert
                shared = NULL;
            }
        }
    }
    return shared;
}

// Load the current address book
+ (ABAddressBookRef) currentAddressBook
{
    if (shared)
    {
        CFRelease(shared);
        shared = nil;
    }
    
    return [self addressBook];
}

// Thanks Frederic Bronner
// Save the address book out
+ (BOOL) save: (NSError **) error
{
    CFErrorRef cfError;
    if (shared)
    {
        BOOL success = ABAddressBookSave(shared, &cfError);
        if (!success)
        {
            if (error)
                *error = (__bridge_transfer NSError *)cfError;
            return NO;
        }        
        return YES;
    }
    return NO;
}

+ (BOOL)hasAddressBookAccess:(ABAddressBookRef)addressBook {
    if (ABAddressBookRequestAccessWithCompletion == NULL) {
        // before iOS 6
        return YES;
    }
    // iOS 6 and more
    __block BOOL accessGranted = NO;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        if(semaphore) {
            dispatch_semaphore_signal(semaphore);
        }
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(semaphore);
    semaphore = NULL;
    
    return accessGranted;
}
@end
