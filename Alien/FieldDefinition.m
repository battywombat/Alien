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

@end
