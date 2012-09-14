//
//  NSString+Helpers.h
//  MyO2
//
//  Created by Ryan Harrison on 2012-09-14.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)

//returns a string of just numbers and no other chars for a alphanumeric string
- (NSString *)strippedNumberString;

@end
