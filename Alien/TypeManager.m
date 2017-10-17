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

-(id)init
{
    self = [super init];
    _basicNamespaces = [[NSMutableDictionary alloc] init];
    [_basicNamespaces addEntriesFromDictionary: @{
                                                  @"std" : @[
                                                          [TypeDeclaration vectorType],
                                                          [TypeDeclaration stringType],
                                                          [TypeDeclaration mapType]
                                                          ]
                                                  }];
    _basicTypes = [[NSMutableArray alloc] init];
    _qualifiers = @[ @"short", @"long", @"unsigned", @"const" ];
    [_basicTypes addObjectsFromArray: @[
                                        [TypeDeclaration intType],
                                        [TypeDeclaration charType],
                                        [TypeDeclaration floatType],
                                        [TypeDeclaration doubleType],
                                        [TypeDeclaration boolType]
                                        ]];
    return self;
}

enum TokenType {
    INVALID,
    NAMESPACE,
    TYPENAME,
    QUALIFIER,
    REFERENCE,
    BEGIN_TYPE_PARAM,
    CONTINUE_TYPE_PARAM,
    END_TYPE_PARAM,
    VOID,
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
    else if ([token isEqualTo: @"void"]) {
        return VOID;
    }
    return INVALID;
}

- (Type *)parseType:(CPPTokenizer *)tokens {
    Type *ty = [[Type alloc] init];
    Type *param;
    NSString *token = [tokens nextToken];
    NSArray<TypeDeclaration *> *validTypes = _types;
    int setNamespaces = 0;
    int typeParamState = 0;
    int ptrState = 0;
    int refState = 0;
    enum TokenType tokentype;
    while ((tokentype = [self tokenType: token withTypes: validTypes]) != INVALID) {
        if (typeParamState > 0 && tokentype != CONTINUE_TYPE_PARAM && tokentype != END_TYPE_PARAM) {
            return nil;
        }
        if (setNamespaces > 0 && tokentype != TYPENAME) {
            return nil;
        }
        if (ptrState > 0 && tokentype != END_TYPE_PARAM && tokentype != CONTINUE_TYPE_PARAM && tokentype != POINTER && (tokentype != QUALIFIER || ![token isEqualTo: @"const"])) {
            return nil;
        }
        if (refState > 0 && tokentype != POINTER) {
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
                setNamespaces = 1;
                break;
            case TYPENAME:
                ty.typeDecl = [self typeWithName: token fromDefns: validTypes];
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
                refState = 1;
                break;
            case POINTER:
                ptrState = 1;
                ty.indirectionCount++;
                break;
            case BEGIN_TYPE_PARAM:
                typeParamState = 1;
            case CONTINUE_TYPE_PARAM:
                if (typeParamState != 1) {
                    goto finish;
                }
                param = [self parseType: tokens];
                if (param == nil) {
                    return nil;
                }
                [ty.typeParameters addObject: param];
                break;
            case END_TYPE_PARAM:
                if (typeParamState == 0) {
                    goto finish;
                }
                typeParamState = 0;
                break;
            case VOID:
                ty.typeDecl = [TypeDeclaration voidType];
                [tokens nextToken]; // Need to make sure we don't rewind to 'void'
                goto finish;
                break; // just because...
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
finish:
    [tokens rewind];
    if (ty.typeDecl == nil) {
        return nil;
    }
    return ty;
}

-(TypeDeclaration *)typeWithName: (NSString *)name fromDefns: (NSArray<TypeDeclaration *> *) defns;
{
    for (TypeDeclaration *defn in defns) {
        if ([defn.name isEqualTo: name]) {
            return defn;
        }
    }
    return nil;
}

-(void) startNewFile
{
    _types = [[self basicTypes] mutableCopy];
    _namespaces = [[self basicNamespaces] mutableCopy];
}

- (void) useNamespace: (NSString *)ns
{
    NSArray<TypeDeclaration *> *arr = [self namespaces][ns];
    if (ns == nil) {
        NSException *exception = [NSException
                                  exceptionWithName: @"InvalidNamespaceException"
                                  reason: [NSString stringWithFormat: @"invalid namespace %@", ns]
                                  userInfo: nil];
        @throw exception;
    }
    for (TypeDeclaration *obj in arr) {
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

- (void)addType:(TypeDeclaration *)ty { 
    for (int i = 0; i < _types.count; i++) {
        if ([_types[i].name isEqualTo: ty.name] && [_types[i] class] == [ClassDeclaration class] && ((ClassDeclaration *)_types[i]).stub) {
            [_types addObject: ty];
            return;
        }
    }
    [_types addObject: ty];
}

@end
