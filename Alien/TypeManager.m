//
//  Definition.m
//  Alien
//
//  Created by Paul Warner on 10/7/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TypeManager.h"


@implementation TypeManager

enum TokenType {
    INVALID,
    NAMESPACE,
    TYPENAME,
    QUALIFIER,
    REFERENCE,
    BEGIN_TYPE_PARAM,
    CONTINUE_TYPE_PARAM,
    END_TYPE_PARAM,
    POINTER
};

- (enum TokenType)tokenType: (NSString *) token withTypes: (NSArray *)validTypes {
    if ([self typeWithName: token fromDefns: validTypes]) {
        return TYPENAME;
    }
    else if (_namespaces[token] != nil) {
        return NAMESPACE;
    }
    else if ([_qualifiers containsObject: token]) {
        return QUALIFIER;
    }
    else if ([token isEqualTo: @"*"]) {
        return POINTER;
    }
    else if ([token isEqualTo: @"&"]) {
        return REFERENCE;
    }
    else if ([token isEqualTo: @"<"]) {
        return BEGIN_TYPE_PARAM;
    }
    else if ([token isEqualTo: @","]) {
        return CONTINUE_TYPE_PARAM;
    }
    else if ([token isEqualTo: @">"]) {
        return END_TYPE_PARAM;
    }
    return INVALID;
}

- (TypeDefinition *)parseType:(CPPTokenizer *)tokens {
    TypeDefinition *ty = [[TypeDefinition alloc] init];
    TypeDefinition *param;
    NSString *token = [tokens nextToken];
    NSArray<TypeDefinition *> *validTypes = _types;
    int setNamespaces = 0;
    int typeParamState = 0;
    int ptrState = 0;
    enum TokenType tokentype;
    while ((tokentype = [self tokenType: token withTypes: validTypes]) != INVALID) {
        if (typeParamState > 0 && tokentype != CONTINUE_TYPE_PARAM && tokentype != END_TYPE_PARAM) {
            return nil;
        }
        if (setNamespaces > 0 && tokentype != TYPENAME) {
            return nil;
        }
        if (ptrState > 0 && tokentype != POINTER && tokentype != QUALIFIER && ![token isEqualTo: @"const"]) {
            return nil;
        }
        switch (tokentype) {
            case NAMESPACE:
                validTypes = _namespaces[token];
                if (validTypes == nil) {
                    return nil; // invalid namespace
                }
                if (![[tokens nextToken] isEqualTo: @"::"]) {
                    return nil;
                }
                ty.containingNamespace = token;
                setNamespaces = 1;
                break;
            case TYPENAME:
                ty.name = token;
                ty.containingNamespace = [self typeWithName: ty.name fromDefns: validTypes].containingNamespace;
                break;
            case QUALIFIER:
                if (ptrState > 0) {
                    ty.constPtr = true;
                }
                else {
                    [ty.qualifiers addObject: token];
                }
                break;
            case REFERENCE:
                ty.isReference = true;
                break;
            case POINTER:
                ptrState = 1;
                ty.indirectionCount++;
                break;
            case BEGIN_TYPE_PARAM:
                typeParamState = 1;
            case CONTINUE_TYPE_PARAM:
                if (typeParamState != 1) {
                    [tokens rewind];
                    return ty;
                }
                param = [self parseType: tokens];
                if (param == nil) {
                    return nil;
                }
                [ty.typeParameters addObject: param];
                break;
            case END_TYPE_PARAM:
                if (typeParamState == 0) {
                    [tokens rewind];
                    return ty; // We've run off the edge during a recursive traversal. Or someone stuck a comma in the middle of their code.
                }
                typeParamState = 0;
                break;
            default:
                return nil;
        }
        setNamespaces = setNamespaces ? setNamespaces+1 : 0;
        if (setNamespaces == 3) {
            setNamespaces = 0;
            validTypes = _types;
        }
        token = [tokens nextToken];
    
    }
    
    
    return ty;
}

+ (TypeManager *)singleton {
    static TypeManager *_singleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _singleton = [[TypeManager alloc] init];
    });
    
    return _singleton;
}

-(id)init
{
    self = [super init];
    _basicNamespaces = [[NSMutableDictionary alloc] init];
    [_basicNamespaces addEntriesFromDictionary: @{
                                                  @"std" : @[
                                                          [[TypeDefinition alloc] initWithName: @"string" inNamespace: @"std"],
                                                          [[TypeDefinition alloc] initWithName: @"vector" inNamespace: @"std" withParams: 1],
                                                          [[TypeDefinition alloc] initWithName: @"map" inNamespace: @"std" withParams: 2]
                                                          ]
                                                  }];
    _basicTypes = [[NSMutableArray alloc] init];
    _qualifiers = @[ @"short", @"long", @"unsigned", @"const" ];
    [_basicTypes addObjectsFromArray: @[
                                        [TypeDefinition intType],
                                        [TypeDefinition charType],
                                        [TypeDefinition floatType],
                                        [TypeDefinition doubleType]
                                        ]];
    return self;
}

-(TypeDefinition *)typeWithName: (NSString *)name fromDefns: (NSArray<TypeDefinition *> *) defns;
{
    for (TypeDefinition *defn in defns) {
        if ([defn.name isEqualTo: name]) {
            return defn;
        }
    }
    return nil;
}

- (void)checkQualifiers: (TypeDefinition *)ty from: (CPPTokenizer *) tokens {
    NSString *current;
    while ([[self qualifiers] containsObject: current = [tokens nextToken]]) {
        [ty.qualifiers addObject: current];
    }
}

-(void) startNewFile
{
    _types = [[self basicTypes] mutableCopy];
    _namespaces = [[self basicNamespaces] mutableCopy];
}

- (void) useNamespace: (NSString *)ns
{
    NSArray<TypeDefinition *> *arr = [self namespaces][ns];
    if (ns == nil) {
        NSException *exception = [NSException
                                  exceptionWithName: @"InvalidNamespaceException"
                                  reason: [NSString stringWithFormat: @"invalid namespace %@", ns]
                                  userInfo: nil];
        @throw exception;
    }
    for (TypeDefinition *obj in arr) {
        [_types addObject: obj];
    }
}

- (void) addNamespace: (NSString *)ns
{
    if ([self namespaces][ns] == nil) {
        return;
    }
    _namespaces[ns] = [[NSMutableArray alloc] init];
}

@end
