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
    self = [super init];
    _name = name;
    _type = INSTANCE;
    _arguments = [[NSArray alloc] init];
    _returnType = [TypeDefinition voidType];
    return self;
}

-(id)init: (NSString *) name returnType: (TypeDefinition *) returnType withArguments: (NSArray<NSArray *> *) arguments {
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
    _returnType = [TypeDefinition voidType];
    return self;
}

- (id)init:(NSString *)name ofType:(enum MethodType)type {
    self = [super init];
    _name = name;
    _type = type;
    _arguments = [[NSArray alloc] init];
    _returnType = [TypeDefinition voidType];
    return self;
}

@end
