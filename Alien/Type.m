//
//  TypeDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/14/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "Type.h"

@implementation Type

- (id) init {
    return [self initWithType: nil];
}

- (id) initWithType:(TypeDeclaration *)type {
    self = [super init];
    _typeDecl = type;
    _isReference = false;
    _indirectionCount = 0;
    _typeParameters = [[NSMutableArray alloc] init];
    _qualifiers = [[NSMutableArray alloc] init];
    return self;
}

-(BOOL)addQualifier: (NSString *) qualifier {
    [_qualifiers addObject: qualifier];
    return true;
}

- (NSString *)type: (BOOL) isNS {
    NSMutableString *s = [[NSMutableString alloc] init];
    NSUInteger i;
    if (_qualifiers.count > 0) {
        i = _qualifiers.count;
        while (i--) {
            [s appendString: [NSString stringWithFormat: @"%@ ", _qualifiers[i]]];
        }
    }
    if (!isNS) { // need to append namespace
        [s appendString: _typeDecl.containingNamespace];
    }
    [s appendString: isNS ? [_typeDecl nameForNS] : [_typeDecl nameForCpp]];
    i = _typeParameters.count;
    if (_typeParameters.count > 0) {
        [s appendString: @"<"];
        for (int j = 0; j < i; j++) {
            [s appendString: isNS ? [_typeParameters[j] typeForNS] : [_typeDecl nameForCpp]];
            if (!(j == i-1)) {
                [s appendString: @","];
            }
        }
        [s appendString: @">"];
    }
    i = _indirectionCount;
    if (![[_typeDecl nameForNS] isEqualTo: _typeDecl.name]) {
        i++;
    }
    if (i > 0) {
        [s appendString: @" "];
        while (i--) {
            [s appendString: @"*"];
        }
        if (_constPtr) {
            [s appendString: @" const"];
        }
    }
    return s;
}

- (NSString *)typeForNS {
    return [self type: YES];
}

- (NSString *)typeWithParens { 
    return [NSString stringWithFormat: @"(%@)", [self typeForNS]];
}

- (NSString *)typeForCpp {
    return [self type: NO];
}

- (NSString *)typeConvertCpp {
    if (_typeDecl.insertionCpp != nil) { // If we have an insertion call, generate a function name
        NSMutableString *s = [[NSMutableString alloc] init];
        [s appendString: [NSString stringWithFormat: @"__convert%@", _typeDecl.name]];
        for (Type *t in self.typeParameters) {
            [s appendString: t.typeDecl.name];
        }
        [s appendString: @"(%@)"];
        return s;
    }
    return _typeDecl.convertCpp == nil ? @"[%@ cppInstance]" : _typeDecl.convertCpp;
}

- (BOOL)isEqual:(id)object {
    if (!([object class] == [Type class])) {
        return false;
    }
    Type *other = (Type *)object;
    return other.typeDecl == nil ? self.typeDecl == nil : [other.typeDecl isEqual: self.typeDecl] &&
           other.constPtr == self.constPtr &&
           other.isReference == self.isReference &&
           other.indirectionCount == self.indirectionCount &&
           other.typeParameters == nil ? self.typeParameters == nil : [other.typeParameters isEqual: self.typeParameters] &&
           other.qualifiers == nil ? self.typeParameters == nil : [other.qualifiers isEqual: self.typeParameters];
}

- (NSUInteger)hash { 
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + (_typeDecl == nil ? 0 : [_typeDecl hash]);
    result = prime * result + (_typeParameters == nil ? 0 : [_typeParameters hash]);
    result = prime * result + _indirectionCount;
    result = prime * result + (_qualifiers == nil ? 0 : [_qualifiers hash]);
    result = prime * result + _isReference ? 1 : 0;
    result = prime * result + _constPtr ? 1 : 0;
    return result;
}

@end
