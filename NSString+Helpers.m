//
//  NSString+Helpers.m
//  MyO2
//
//  Created by Ryan Harrison on 2012-09-14.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)

//returns a string of just numbers and no other chars for a alphanumeric string
- (NSString *)strippedNumberString{
    return [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

@end
