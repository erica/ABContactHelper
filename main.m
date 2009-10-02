/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@end

@implementation TestBedViewController
@synthesize log;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	textView.text = self.log;
}

- (void) addGW
{
	// Search for a contact, creating a new one if one is not found
	NSArray *contacts = [ABContactsHelper contactsMatchingName:@"Washington" andName:@"George"];
	printf("%d matching contacts found\n", contacts.count);
	ABContact *peep = contacts.count ? [contacts lastObject] : [ABContact contact];
	
	if (contacts.count) 
	{
		NSError *error;
		if (![peep removeSelfFromAddressBook:&error]) // remove in preparation to update contact
		{
			NSLog(@"Error: %@", [error localizedDescription]);
			return;
		}
		
	}

	printf("Record %d\n", peep.recordID);
	
	// Person basic string information (see full list in ABContact)
	peep.firstname = @"George";
	peep.lastname = @"Washington";
	peep.nickname = @"Prez";
	peep.firstnamephonetic = @"Horhay";
	peep.lastnamephonetic = @"Warsh-ing-town";
	peep.jobtitle = @"President of the United States of America";
	
	// Emails
	NSMutableArray *emailarray = [NSMutableArray array];
	[emailarray addObject:[ABContact dictionaryWithValue:@"george@home.com" andLabel:kABHomeLabel]];
	[emailarray addObject:[ABContact dictionaryWithValue:@"george@work.com" andLabel:kABWorkLabel]];
	[emailarray addObject:[ABContact dictionaryWithValue:@"george@gmail.com" andLabel:(CFStringRef) @"Google"]];
	peep.emailDictionaries = emailarray;
	
	// Phones
	NSMutableArray *phonearray = [NSMutableArray array];
	[phonearray addObject:[ABContact dictionaryWithValue:@"202-555-1212" andLabel:kABPersonPhoneMainLabel]];
	[phonearray addObject:[ABContact dictionaryWithValue:@"202-555-1313" andLabel:(CFStringRef) @"Google"]];
	[phonearray addObject:[ABContact dictionaryWithValue:@"202-555-1414" andLabel:kABPersonPhoneMobileLabel]];
	peep.phoneDictionaries = phonearray;
	
	// URLS
	NSMutableArray *urls = [NSMutableArray array];
	[urls addObject:[ABContact dictionaryWithValue:@"http://whitehouse.org" andLabel:kABPersonHomePageLabel]];
	[urls addObject:[ABContact dictionaryWithValue:@"http://en.wikipedia.org/wiki/Washington" andLabel:kABOtherLabel]];
	peep.urlDictionaries = urls;
	
	// Dates
	NSMutableArray *dates = [NSMutableArray array];
	[dates addObject:[ABContact dictionaryWithValue:[NSDate dateWithTimeIntervalSinceNow:0] andLabel:(CFStringRef) @"Anniversary"]];
	peep.dateDictionaries = dates;
	
	// Addresses
	NSMutableArray *addies = [NSMutableArray array];
	NSDictionary *whaddy = [ABContact addressWithStreet:@"1600 Pennsylvania Avenue" withCity:@"Arlington" withState:@"Virginia" withZip:@"20202" withCountry:nil withCode:nil];
	[addies addObject:[ABContact dictionaryWithValue:whaddy andLabel:kABWorkLabel]];
	NSDictionary *bpaddy = [ABContact addressWithStreet:@"1 Main Street" withCity:@"Westmoreland" withState:@"Virginia" withZip:@"20333" withCountry:nil withCode:nil];
	[addies addObject:[ABContact dictionaryWithValue:bpaddy andLabel:kABHomeLabel]];
	peep.addressDictionaries = addies;

	// SMSes
	NSDictionary *sms = [ABContact smsWithService:kABPersonInstantMessageServiceAIM andUser:@"geow1735"];
	NSMutableArray *smses = [NSMutableArray array];
	[smses addObject:[ABContact dictionaryWithValue:sms andLabel:kABWorkLabel]];
	peep.smsDictionaries = smses;
	
	// Relationships (Not actually used on the iPhone, but here for the sake of example)
	 NSMutableArray *relatedarray = [NSMutableArray array];
	[relatedarray addObject:[ABContact dictionaryWithValue:@"Mary Ball Washington" andLabel:kABPersonMotherLabel]];
	[relatedarray addObject:[ABContact dictionaryWithValue:@"Augustine Washington" andLabel:kABPersonFatherLabel]];
	 peep.relatedNameDictionaries = relatedarray;
	
	NSError *error;
	if (![ABContactsHelper addContact:peep withError:&error]) // save to address book
		NSLog(@"Error: %@", [error localizedDescription]);
}

- (void) scan
{
	// Regular data dump
	for (ABContact *person in [ABContactsHelper contacts])
	{
		printf("******\n");
		printf("Name: %s\n", person.compositeName.UTF8String);
		printf("Organization: %s\n", person.organization.UTF8String);
		printf("Title: %s\n", person.jobtitle.UTF8String);
		printf("Department: %s\n", person.department.UTF8String);
		printf("Note: %s\n", person.note.UTF8String);
		printf("Creation Date: %s\n", [person.creationDate description].UTF8String);
		printf("Modification Date: %s\n", [person.modificationDate description].UTF8String);
		printf("Emails: %s\n", [person.emailDictionaries description].UTF8String);
		printf("Phones: %s\n", [person.phoneDictionaries description].UTF8String);
		printf("URLs: %s\n", [person.urlDictionaries description].UTF8String);
		printf("Addresses: %s\n\n", [person.addressDictionaries description].UTF8String);
	}
	
	// Example for matching phone numbers
	for (ABContact *person in [ABContactsHelper contactsMatchingPhone:@"303"])
	{
		printf("******\n");
		printf("Name: %s\n", person.compositeName.UTF8String);
		printf("Phones: %s\n", person.phonenumbers.UTF8String);
	}
	
	// Example for matching names
	for (ABContact *person in [ABContactsHelper contactsMatchingName:@"Jo"])
	{
		printf("******\n");
		printf("Name: %s\n", person.contactName.UTF8String);
	}
}

- (void) viewgroups
{
	printf("There are %d groups\n", [ABContactsHelper numberOfGroups]);
	for (ABGroup *group in [ABContactsHelper groups])
	{
		printf("Name: %s\n", group.name.UTF8String);
		NSArray *members = group.members;
		printf("Members: %d\n", members.count);

		int n = 1;
		for (ABContact *contact in members)
			printf("%d: %s\n", n++, contact.compositeName.UTF8String);
	}
}

- (void) addGroup
{
	NSArray *groups = [ABContactsHelper groupsMatchingName:@"Everyone"];
	printf("%d matching groups found\n", groups.count);
	ABGroup *group = groups.count ? [groups lastObject] : [ABGroup group];
	
	// Remove existing group to allow modification
	if (groups.count) [group removeSelfFromAddressBook:nil];

	// set name
	group.name = @"Everyone";
	
	// add members
	NSArray *contacts = [ABContactsHelper contacts];
	for (ABContact *contact in contacts)
		[group addMember:contact withError:nil];

	// Save the new or modified group
	[ABContactsHelper addGroup:group withError:nil];
}

- (void) serialize
{
	NSArray *contacts = [ABContactsHelper contactsMatchingName:@"Washington" andName:@"George"];
	printf("%d matching contacts found\n", contacts.count);
	ABContact *peep = contacts.count ? [contacts lastObject] : [ABContact contact];	
	if (!peep) return;
	
	NSDictionary *dict = [peep dictionaryRepresentation];
	CFShow(dict);
	
	NSData *data = [peep dataRepresentation];
	printf("%d bytes\n", data.length);
	
	ABContact *contact = [ABContact contactWithData:data];
	CFShow([contact dictionaryRepresentation]);
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// BASIC TEST
	// self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add GW", @selector(addGW));
	// self.navigationItem.leftBarButtonItem = BARBUTTON(@"Scan", @selector(scan));

	// GROUPS TEST
	// self.navigationItem.rightBarButtonItem = BARBUTTON(@"Groups", @selector(viewgroups));
	// self.navigationItem.leftBarButtonItem = BARBUTTON(@"Add", @selector(addGroup));
	
	// SERIALIZATION TEST
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Serialize", @selector(serialize));
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
