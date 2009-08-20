/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ABContact.h"

@interface ABContactsHelper : NSObject

// Address Book Contacts
+ (NSArray *) contacts; // people

// Counting
+ (int) contactsCount;
+ (int) contactsWithImageCount;
+ (int) contactsWithoutImageCount;

// Sorting
+ (BOOL) firstNameSorting;

// Add contacts
+ (NSString *) addContact: (ABContact *) aContact;

// Find contacts
+ (ABContact *) contactWithID: (ABRecordID) aRecordID;
+ (NSArray *) contactsMatchingName: (NSString *) fname;
+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname;
@end

// For the simple utility of it. Feel free to comment out if desired
@interface NSString (cstring)
@property (readonly) char *UTF8String;
@end