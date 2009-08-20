/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABContact : NSObject
{
	ABRecordRef record;
}

// Convenience methods
+ (id) contact;
+ (id) contactWithRecord: (ABRecordRef) record;

// Class utility methods
+ (NSString *) cleanLabel: (NSString *) aLabel;
+ (CFStringRef) formattedLabel: (NSString *) aLabel;
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty;
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty;
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty;

// Creating proper dictionaries
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code;
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName;

// Instance utility methods
- (NSString *) removeSelfFromAddressBook;

@property (readonly) ABRecordRef record;
@property (readonly) ABRecordID recordID;
@property (readonly) ABRecordType recordType;
@property (readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (assign) NSString *firstname;
@property (assign) NSString *lastname;
@property (assign) NSString *middlename;
@property (assign) NSString *prefix;
@property (assign) NSString *suffix;
@property (assign) NSString *nickname;
@property (assign) NSString *firstnamephonetic;
@property (assign) NSString *lastnamephonetic;
@property (assign) NSString *middlenamephonetic;
@property (assign) NSString *organization;
@property (assign) NSString *jobtitle;
@property (assign) NSString *department;
@property (assign) NSString *note;

@property (readonly) NSString *contactName; // my friendly utility
@property (readonly) NSString *compositeName; // via AB

#pragma mark DATE
@property (readonly) NSDate *birthday;
@property (readonly) NSDate *creationDate;
@property (readonly) NSDate *modificationDate;

#pragma mark MULTIVALUE
// Each of these produces an array of NSStrings
@property (readonly) NSArray *emailArray;
@property (readonly) NSArray *emailLabels;
@property (readonly) NSArray *phoneArray;
@property (readonly) NSArray *phoneLabels;
@property (readonly) NSArray *relatedNameArray;
@property (readonly) NSArray *relatedNameLabels;
@property (readonly) NSArray *urlArray;
@property (readonly) NSArray *urlLabels;
@property (readonly) NSArray *dateArray;
@property (readonly) NSArray *dateLabels;
@property (readonly) NSArray *addressArray;
@property (readonly) NSArray *addressLabels;
@property (readonly) NSArray *smsArray;
@property (readonly) NSArray *smsLabels;

@property (readonly) NSString *emailaddresses;
@property (readonly) NSString *phonenumbers;
@property (readonly) NSString *urls;

// Each of these uses an array of dictionaries
@property (assign) NSArray *emailDictionaries;
@property (assign) NSArray *phoneDictionaries;
@property (assign) NSArray *relatedNameDictionaries;
@property (assign) NSArray *urlDictionaries;
@property (assign) NSArray *dateDictionaries;
@property (assign) NSArray *addressDictionaries;
@property (assign) NSArray *smsDictionaries;

#pragma mark IMAGES
@property (assign) UIImage *image;

@end