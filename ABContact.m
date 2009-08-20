/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContact.h"
#import "ABContactsHelper.h"

@implementation ABContact
@synthesize record;

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
	if (self = [super init]) record = CFRetain(aRecord);
	return self;
}

+ (id) contactWithRecord: (ABRecordRef) person
{
	return [[[ABContact alloc] initWithRecord:person] autorelease];
}

// Thanks to Ciaran
+ (id) contact
{
	ABRecordRef person = ABPersonCreate();
	id contact = [ABContact contactWithRecord:person];
	CFRelease(person);
	return contact;
}

- (void) dealloc
{
	if (record) CFRelease(record);
	[super dealloc];
}

#pragma mark utilities
+ (NSString *) cleanLabel: (NSString *) aLabel
{
	return [[aLabel stringByReplacingOccurrencesOfString:@"_$!<" withString:@""] stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
}

+ (CFStringRef) formattedLabel: (NSString *) aLabel
{
	return (CFStringRef) [NSString stringWithFormat:@"_$!<%@>!$_", aLabel];
}

+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty
{
	NSString *propertyName = (NSString *)ABPersonCopyLocalizedPropertyName(aProperty);
	return [propertyName autorelease];
}

+ (ABPropertyType) propertyType: (ABPropertyID) aProperty
{
	return ABPersonGetTypeOfProperty(aProperty);
}

+ (NSString *) propertyTypeString: (ABPropertyID) aProperty
{
	ABPropertyType ptype = ABPersonGetTypeOfProperty(aProperty);
	if (ptype == kABInvalidPropertyType) return @"Invalid Property";
	if (ptype == kABStringPropertyType) return @"String";
	if (ptype == kABIntegerPropertyType) return @"Integer";
	if (ptype == kABRealPropertyType) return @"Float";
	if (ptype == kABDateTimePropertyType) return @"value";
	if (ptype == kABDictionaryPropertyType) return @"Dictionary";
	if (ptype == kABMultiStringPropertyType) return @"Multi String";
	if (ptype == kABMultiIntegerPropertyType) return @"Multi Integer";
	if (ptype == kABMultiRealPropertyType) return @"Multi Float";
	if (ptype == kABMultiDateTimePropertyType) return @"Multi Date";
	if (ptype == kABMultiDictionaryPropertyType) return @"Multi Dictionary";
	return @"Invalid Property";
}

+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (value) [dict setObject:value forKey:@"value"];
	if (label) [dict setObject:(NSString *)label forKey:@"label"];
	return dict;
}

+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code
{
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
	if (street) [md setObject:street forKey:(NSString *) kABPersonAddressStreetKey];
	if (city) [md setObject:city forKey:(NSString *) kABPersonAddressCityKey];
	if (state) [md setObject:state forKey:(NSString *) kABPersonAddressStateKey];
	if (zip) [md setObject:zip forKey:(NSString *) kABPersonAddressZIPKey];
	if (country) [md setObject:country forKey:(NSString *) kABPersonAddressCountryKey];
	if (code) [md setObject:code forKey:(NSString *) kABPersonAddressCountryCodeKey];
	return md;
}

+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName
{
	NSMutableDictionary *sms = [NSMutableDictionary dictionary];
	if (service) [sms setObject:(NSString *) service forKey:(NSString *) kABPersonInstantMessageServiceKey];
	if (userName) [sms setObject:userName forKey:(NSString *) kABPersonInstantMessageUsernameKey];
	return sms;
}

- (NSString *) removeSelfFromAddressBook
{
	// Record still exists after operation but is not in address book
	// Fetch the record back to recover its proper id
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFErrorRef error;
	BOOL success = ABAddressBookRemoveRecord(addressBook, self.record, &error);
	if (!success) return [(NSError *)error localizedDescription];	
	success = ABAddressBookSave(addressBook, &error);
	return success ? nil : [(NSError *)error localizedDescription];
}

#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark Getting Single Value Strings
- (NSString *) getRecordString:(ABPropertyID) anID
{
	return [(NSString *) ABRecordCopyValue(record, anID) autorelease];
}
- (NSString *) firstname {return [self getRecordString:kABPersonFirstNameProperty];}
- (NSString *) lastname {return [self getRecordString:kABPersonLastNameProperty];}
- (NSString *) middlename {return [self getRecordString:kABPersonMiddleNameProperty];}
- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}
- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) organization {return [self getRecordString:kABPersonOrganizationProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}

#pragma mark Contact Name Utility
- (NSString *) contactName
{
	NSMutableString *string = [NSMutableString string];
	
	if (self.firstname || self.lastname)
	{
		if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
		if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
		if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
		if (self.lastname) [string appendFormat:@"%@", self.lastname];
		
		if (self.suffix && string.length)
			[string appendFormat:@", %@ ", self.suffix];
		else
			[string appendFormat:@" "];
	}
	
	if (self.organization) [string appendFormat:self.organization];
	
	return string;
}

- (NSString *) compositeName
{
	NSString *string = (NSString *)ABRecordCopyCompositeName(record);
	return [string autorelease];
}

#pragma mark Dates
- (NSDate *) getRecordDate:(ABPropertyID) anID
{
	return [(NSDate *) ABRecordCopyValue(record, anID) autorelease];
}

- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}

#pragma mark Getting MultiValue Elements
- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSArray *items = (NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	CFRelease(theProperty);
	return [items autorelease];
}

- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSMutableArray *labels = [NSMutableArray array];
	for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
	{
		NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
		[labels addObject:label];
		[label release];
	}
	CFRelease(theProperty);
	return labels;
}

- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}
- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}
- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}
- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}
- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}
- (NSArray *) smsArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) smsLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}

- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
	NSArray *valueArray = [self arrayForProperty:aProperty];
	NSArray *labelArray = [self labelsForProperty:aProperty];
	
	int num = MIN(valueArray.count, labelArray.count);
	NSMutableArray *items = [NSMutableArray array];
	for (int i = 0; i < num; i++)
	{
		NSMutableDictionary *md = [NSMutableDictionary dictionary];
		[md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
		[md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
		[items addObject:md];
	}
	return items;
}

- (NSArray *) emailDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}

- (NSArray *) phoneDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}

- (NSArray *) relatedNameDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}

- (NSArray *) urlDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonURLProperty];
}

- (NSArray *) dateDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonDateProperty];
}

- (NSArray *) addressDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonAddressProperty];
}

- (NSArray *) smsDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}

#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, anID, (CFStringRef) aString, &error);
	if (!success) NSLog(@"Error: %@", [(NSError *)error localizedDescription]);
	return success;
}

- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}
- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}
- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}

#pragma mark Setting MultiValue

- (BOOL) setMulti: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, anID, multi, &error);
	if (!success) NSLog(@"Error: %@", [(NSError *)error localizedDescription]);
	return success;
}
- (ABMutableMultiValueRef) createMultiValueFromArray: (NSArray *) anArray withType: (ABPropertyType) aType
{
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(aType);
	for (NSDictionary *dict in anArray)
		ABMultiValueAddValueAndLabel(multi, (CFTypeRef) [dict objectForKey:@"value"], (CFTypeRef) [dict objectForKey:@"label"], NULL);
	return multi;
}

- (void) setEmailDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
	[self setMulti:multi forProperty:kABPersonEmailProperty];
}

- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
	// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
	[self setMulti:multi forProperty:kABPersonPhoneProperty];
}

- (void) setUrlDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonHomePageLabel
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
	[self setMulti:multi forProperty:kABPersonURLProperty];
}

// Not used/shown on iPhone
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel, 
	// kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel, 
	// kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel, 
	// kABPersonManagerLabel, kABPersonAssistantLabel
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
	[self setMulti:multi forProperty:kABPersonRelatedNamesProperty];
}

- (void) setDateDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonAnniversaryLabel
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDateTimePropertyType];
	[self setMulti:multi forProperty:kABPersonDateProperty];
}

- (void) setAddressDictionaries: (NSArray *) dictionaries
{
	// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
	// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
	[self setMulti:multi forProperty:kABPersonAddressProperty];
}

- (void) setSmsDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel, 
	// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
	// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
	// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
	// kABPersonInstantMessageServiceAIM, 
	ABMutableMultiValueRef multi = [self createMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
	[self setMulti:multi forProperty:kABPersonInstantMessageProperty];
}

#pragma mark Images
- (UIImage *) image
{
	if (!ABPersonHasImageData(record)) return nil;
	CFDataRef imageData = ABPersonCopyImageData(record);
	UIImage *image = [UIImage imageWithData:(NSData *) imageData];
	CFRelease(imageData);
	return image;
}

- (void) setImage: (UIImage *) image
{
	CFErrorRef error;
	BOOL success;
	
	if (image == nil) // remove
	{
		if (!ABPersonHasImageData(record)) return; // no image to remove
		success = ABPersonRemoveImageData(record, &error);
		if (!success) NSLog(@"Error: %@", [(NSError *)error localizedDescription]);
		return;
	}
	
	NSData *data = UIImagePNGRepresentation(image);
	success = ABPersonSetImageData(record, (CFDataRef) data, &error);
	if (!success) NSLog(@"Error: %@", [(NSError *)error localizedDescription]);
}
@end