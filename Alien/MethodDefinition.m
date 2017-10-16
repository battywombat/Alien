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


- (id)init:(NSString *)name {
    return [self init: name withArguments: @[] ofType: INSTANCE];
}

-(id)init: (NSString *) name returnType: (Type *) returnType withArguments: (NSArray<NSArray *> *) arguments {
    self = [super init];
    _name = name;
    _type = INSTANCE;
    _arguments = arguments;
    _returnType = returnType;
    return self;
}

- (id)init:(NSString *)name withArguments:(NSArray<NSArray *> *)arguments ofType:(enum MethodType)type {
    self = [super init];
    _name = name;
    _type = type;
    _arguments = arguments;
    _returnType = [[Type alloc] initWithType: [TypeDeclaration voidType]];
    return self;
}

- (id)init:(NSString *)name ofType:(enum MethodType)type {
    return [self init: name withArguments: @[] ofType: type];
}

@end
