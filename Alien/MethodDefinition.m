//
//  MethodDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MethodDefinition.h"

@implementation MethodDefinition

-(id)init: (NSString *) name returnType: (Type *) returnType withArguments: (NSArray<NSArray *> *) arguments withAccessLevel: (enum AccessLevel) accessLevel {
    self = [super initWithName: name andType: returnType andAccessLevel: accessLevel];
    _methodType = INSTANCE;
    _arguments = arguments;
    return self;
}

- (id)init:(NSString *)name withArguments:(NSArray<NSArray *> *)arguments ofType:(enum MethodType)type withAccessLevel: (enum AccessLevel) accessLevel {
    self = [super initWithName: name andType: nil andAccessLevel: accessLevel];
    _arguments = arguments;
    _methodType = type;
    return self;
}

- (id)init:(NSString *)name ofType:(enum MethodType)type withAccessLevel: (enum AccessLevel) accessLevel {
    return [self init: name withArguments: @[] ofType: type withAccessLevel: accessLevel];
}

@end
