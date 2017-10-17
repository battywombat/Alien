//
//  TypeDeclaration.m
//  Alien
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "TypeDeclaration.h"

@implementation TypeDeclaration

- (id)init {
    return [self initWithName: nil inNamespace: nil];
}

-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns {
    return [self initWithName: name inNamespace: ns withParams: 0];
}

- (id)initWithName:(NSString *)name inNamespace:(NSString *)ns withParams:(NSUInteger)nParams {
    self = [super init];
    _name = name;
    _containingNamespace = ns;
    _nTypeParameters = nParams;
    _customName = nil;
    return self;
}

-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withCustomName: (NSString *) otherName
{
    self = [self initWithName: name inNamespace: ns withParams: 0];
    _customName = otherName;
    return self;
}

+ (TypeDeclaration *)voidType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"void";
    return defn;
}

+ (TypeDeclaration *)intType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"int";
    return defn;
}

+ (TypeDeclaration *)charType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"char";
    return defn;
}

+ (TypeDeclaration *)floatType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"float";
    return defn;
}

+ (TypeDeclaration *)doubleType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"double";
    return defn;
}

+ (TypeDeclaration *)stringType {
    return [[TypeDeclaration alloc] initWithName: @"string" inNamespace: @"std" withCustomName: @"NSString"];
}

+ (TypeDeclaration *)vectorType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] initWithName: @"vector" inNamespace: @"std" withCustomName: @"NSMutableArray"];
    defn.nTypeParameters = 1;
    return defn;
}

+ (TypeDeclaration *)mapType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] initWithName: @"map" inNamespace: @"std" withCustomName: @"NSMutableDictionary"];
    defn.nTypeParameters = 2;
    return defn;
}



- (NSString *) nameforNS {
    return _customName == nil ? self.name : _customName;
}

+ (TypeDeclaration *)boolType { 
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"bool";
    defn.customName = @"BOOL";
    return defn;
}

@end
