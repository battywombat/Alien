//
//  TypeDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/14/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "TypeDefinition.h"

@implementation TypeDefinition

-(id)init
{
    self = [super init];
    _name = nil;
    _containingNamespace = nil;
    _typeParameters = [[NSMutableArray alloc] init];
    _qualifiers = [[NSMutableArray alloc] init];
    _indirectionCount = 0;
    return self;
    
}

-(id)initWithName: (NSString *)name inNamespace: (NSString *) ns
{
    self = [super init];
    _name = name;
    _containingNamespace = ns;
    _typeParameters = [[NSMutableArray alloc] init];
    _qualifiers = [[NSMutableArray alloc] init];
    _indirectionCount = 0;
    return self;
}

-(id)initWithName: (NSString *)name inNamespace: (NSString *) ns withParams: (NSUInteger) count
{
    self = [super init];
    _name = name;
    _containingNamespace = ns;
    _typeParameters = [[NSMutableArray alloc] init];
    while (count--) {
        [_typeParameters addObject: [[TypeDefinition alloc] init]];
    }
    _qualifiers = [[NSMutableArray alloc] init];
    _indirectionCount = 0;
    return self;
}

+ (TypeDefinition *)voidType { 
    TypeDefinition *defn = [[TypeDefinition alloc] init];
    defn.name = @"void";
    return defn;
}

+ (TypeDefinition *)intType {
    TypeDefinition *defn = [[TypeDefinition alloc] init];
    defn.name = @"int";
    return defn;
}

+ (TypeDefinition *)charType { 
    TypeDefinition *defn = [[TypeDefinition alloc] init];
    defn.name = @"char";
    return defn;
}

+ (TypeDefinition *)floatType { 
    TypeDefinition *defn = [[TypeDefinition alloc] init];
    defn.name = @"float";
    return defn;
}

+ (TypeDefinition *)doubleType {
    TypeDefinition *defn = [[TypeDefinition alloc] init];
    defn.name = @"double";
    return defn;
}

@end
