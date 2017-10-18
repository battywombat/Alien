//
//  FieldDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "FieldDefinition.h"

@implementation FieldDefinition

-(id)initWithName : (NSString *) name andType: (Type *) type
{
    return [self initWithName: name andType: type andAccessLevel: PRIVATE];
}

-(id)initWithName : (NSString *) name andType: (Type *) type andAccessLevel: (enum AccessLevel) accessLevel {
    self = [super init];
    _name = name;
    _type = type;
    _accessLevel = accessLevel;
    _isStatic = false;
    return self;
}

- (NSString *)createNSHeader { 
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendString: @"@property "];
    [s appendString: [[self type] typeForNS]];
    [s appendString: @" "];
    [s appendString: [self name]];
    [s appendString: @";"];
    return s;
}

@end
