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

- (id)init {
    self = [super init];
    _methodType = NORMAL;
    _arguments = @[];
    _isVirtual = false;
    return self;
}

-(id)init: (NSString *) name returnType: (Type *) returnType withArguments: (NSArray<NSArray *> *) arguments withAccessLevel: (enum AccessLevel) accessLevel {
    self = [super initWithName: name andType: returnType andAccessLevel: accessLevel];
    _methodType = NORMAL;
    _arguments = arguments;
    _isVirtual = false;
    return self;
}

- (id)init:(NSString *)name withArguments:(NSArray<NSArray *> *)arguments ofType:(enum MethodType)type withAccessLevel: (enum AccessLevel) accessLevel {
    self = [super initWithName: name andType: [[Type alloc] initWithType: [TypeDeclaration voidType]] andAccessLevel: accessLevel];
    _arguments = arguments;
    _methodType = type;
    _isVirtual = false;
    return self;
}

- (id)init:(NSString *)name ofType:(enum MethodType)type withAccessLevel: (enum AccessLevel) accessLevel {
    return [self init: name withArguments: @[] ofType: type withAccessLevel: accessLevel];
}

-(NSString *)createNSHeader {
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendString: [self isStatic] ? @"+" : @"-"];
    if (_methodType == INIT) {
        [s appendString: @"(id)init"];
    }
    else {
        [s appendString: [[self type] typeWithParens]];
        [s appendString: [self name]];
    }
    for (int i = 0; i < [self arguments].count; i++) {
        if (i > 0) {
            [s appendString: @" "];
            [s appendString: _arguments[i][1]];
        }
        [s appendString: @":"];
        [s appendString: [NSString stringWithFormat: @" %@ ", [_arguments[i][0] typeWithParens]]];
        [s appendString: _arguments[i][1]];
    }
    return s;
}

- (NSString *)createNSBody {
    // TODO: implement this
    return nil;
}

@end
