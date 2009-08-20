/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContactsHelper.h"

@implementation ABContactsHelper
+ (NSArray *) contacts
{
	NSMutableArray *array = [NSMutableArray array];
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	for (id person in thePeople)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
	[thePeople release];
	return array;
}

+ (int) contactsCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	return ABAddressBookGetPersonCount(addressBook);
}

+ (int) contactsWithImageCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *peopleArray = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (ABPersonHasImageData(person)) ncount++;
	[peopleArray release];
	return ncount;
}

+ (int) contactsWithoutImageCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *peopleArray = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (!ABPersonHasImageData(person)) ncount++;
	[peopleArray release];
	return ncount;
}

// Sorting
+ (BOOL) firstNameSorting
{
	return (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst);
}

#pragma mark Contact Management
+ (NSString *) addContact: (ABContact *) aContact
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFErrorRef error;
	BOOL success = ABAddressBookAddRecord(addressBook, aContact.record, &error);
	if (!success) return [(NSError *)error localizedDescription];	
	success = ABAddressBookSave(addressBook, &error);
	return success ? nil : [(NSError *)error localizedDescription];
}

+ (ABContact *) contactWithID: (ABRecordID) aRecordID
{
	NSArray *contacts = [ABContactsHelper contacts];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"recordID == %d", aRecordID];
	NSArray *results = [contacts filteredArrayUsingPredicate:pred];
	return results.count ? [results lastObject] : nil;
}

+ (NSArray *) contactsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	return contacts;
}

+ (NSArray *) contactsMatchingPhone: (NSString *) number
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
	return [contacts filteredArrayUsingPredicate:pred];
}
@end