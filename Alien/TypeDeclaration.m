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

- (NSString *) convertBlockNS: (NSString *) src to: (NSString *) dst {
    NSMutableString *conv = [NSMutableString stringWithString: _convertBlockCppBase];
    [conv replaceOccurrencesOfString: @"%a" withString: src options: NSLiteralSearch range: NSMakeRange(0, conv.length)];
    [conv replaceOccurrencesOfString: @"%b" withString: dst options: NSLiteralSearch range: NSMakeRange(0, conv.length)];
    return conv;
}

- (NSString *) typeInitCpp {
    return _typeInitNS;
}

- (void) setTypeInitCpp: (NSString *) typeInitNS {
    _typeInitNS = typeInitNS;
}

- (NSString *) nameForNS {
    return _customName == nil ? self.name : _customName;
}

- (NSString *) nameForCpp {
    return self.name;
}


+ (TypeDeclaration *)voidType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"void";
    return defn;
}

+ (TypeDeclaration *)intType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"int";
    defn.convertCpp = @"%@";
    return defn;
}

+ (TypeDeclaration *)charType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"char";
    defn.convertCpp = @"%@";
    return defn;
}

+ (TypeDeclaration *)floatType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"float";
    defn.convertCpp = @"%@";
    return defn;
}

+ (TypeDeclaration *)doubleType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"double";
    defn.convertCpp = @"%@";
    return defn;
}

+ (TypeDeclaration *)stringType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] initWithName: @"string" inNamespace: @"std" withCustomName: @"NSString"];
    defn.convertCpp = @"[%@ UTF8String]";
    return defn;
}

+ (TypeDeclaration *)vectorType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] initWithName: @"vector" inNamespace: @"std" withCustomName: @"NSMutableArray"];
    defn.nTypeParameters = 1;
    defn.insertionNS = @"[%@ addObject: %@]";
    defn.insertionCpp = @"%@.push_back(%@)";
    return defn;
}

+ (TypeDeclaration *)mapType {
    TypeDeclaration *defn = [[TypeDeclaration alloc] initWithName: @"map" inNamespace: @"std" withCustomName: @"NSMutableDictionary"];
    defn.insertionNS = @"%@[%@] = %@";
    defn.insertionCpp = defn.insertionNS;
    defn.nTypeParameters = 2;
    return defn;
}

+ (TypeDeclaration *)boolType { 
    TypeDeclaration *defn = [[TypeDeclaration alloc] init];
    defn.name = @"bool";
    defn.customName = @"BOOL";
    defn.convertCpp = @"%@";
    return defn;
}

- (BOOL)isEqual:(id)object { 
    if ([object class] != [TypeDeclaration class]) {
        return false;
    }
    TypeDeclaration *other = (TypeDeclaration *)object;
    return other.name == nil ? self.name == nil : [other.name isEqual: self.name] &&
        other.containingNamespace == nil ? self.containingNamespace == nil : [other.containingNamespace isEqual: self.containingNamespace] &&
        other.nTypeParameters == self.nTypeParameters;
}

- (NSUInteger)hash { 
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + (_name == nil ? 0 : [_name hash]);
    result = prime * result + (_containingNamespace == nil ? 0 : [_containingNamespace hash]);
    result = prime * result + _nTypeParameters;
    return result;
}

@end
