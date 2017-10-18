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

- (NSString *)typeForNS {
    NSMutableString *s = [[NSMutableString alloc] init];
    NSUInteger i;
    if (_qualifiers.count > 0) {
        i = _qualifiers.count;
        while (i--) {
            [s appendString: [NSString stringWithFormat: @"%@ ", _qualifiers[i]]];
        }
    }
    [s appendString: [_typeDecl nameforNS]];
    i = _typeParameters.count;
    if (_typeParameters.count > 0) {
        [s appendString: @"<"];
        for (int j = 0; j < i; j++) {
            [s appendString: [_typeParameters[j] typeForNS]];
            if (!(j == i-1)) {
                [s appendString: @","];
            }
        }
        [s appendString: @">"];
    }
    i = _indirectionCount;
    if (![[_typeDecl nameforNS] isEqualTo: _typeDecl.name]) {
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

- (NSString *)typeWithParens { 
    return [NSString stringWithFormat: @"(%@)", [self typeForNS]];
}

- (NSString *)typeInitNS: (NSString *) decl {
    if ([self typeParameters].count == 0) {
        [NSString stringWithFormat: [self typeDecl].typeInitNS, decl];
    }
    return nil; // TODO add initalizers with sub types
}

- (NSString *)convertToNS:(NSString *)srcDecl dest:(NSString *)destDecl {
    NSString *initalizer = [NSString stringWithFormat: @" %@ %@ = %@;", [self typeForNS], srcDecl, [self typeInitNS: destDecl]];
    NSString *convertBlock;
    if ([self typeDecl].convertBlockNSBase != nil) {
        convertBlock = [[self typeDecl] convertBlockNS: srcDecl to: destDecl];
    }
    return convertBlock == nil ? initalizer : [initalizer stringByAppendingString: convertBlock];
}

@end
