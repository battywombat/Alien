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
    _qualifiers = @[ @"short", @"long", @"unsigned" ];
    [_basicTypes addObjectsFromArray: @[
                                        [TypeDefinition intType],
                                        [TypeDefinition charType],
                                        [TypeDefinition floatType],
                                        [TypeDefinition doubleType]
                                        ]];
    return self;
}

-(TypeDefinition *)parseType: (CPPTokenizer *) tokens
{
    TypeDefinition *ty = [[TypeDefinition alloc] init];
    TypeDefinition *template = nil;
    NSString *current = [tokens nextToken];
    NSArray<TypeDefinition *> *nsContents = [self namespaces][current];
    if (nsContents != nil) {
        BOOL flag = false;
        ty.containingNamespace = current;
        if (![[tokens nextToken] isEqualTo: @"::"]) {
            return nil;
        }
        ty.name = [tokens nextToken];
        for (TypeDefinition *defn in  nsContents) {
            if ([defn.name isEqualTo: ty.name]) {
                template = defn;
                flag = true;
                break;
            }
        }
        if (!flag) {
            return nil;
        }
    }
    else if ([[self qualifiers] containsObject: current]) {
        [ty.qualifiers addObject: current];
        while ([[self qualifiers] containsObject: current = [tokens nextToken]]) {
            [ty.qualifiers addObject: current];
        }
    }
    if ([self typeWithName: current]) {
        template = [self typeWithName: current];
        ty.name = current;
        ty.containingNamespace = template.containingNamespace;
    }
    
    if (template != nil && template.typeParameters.count > 0) {
        NSUInteger nTemplates = template.typeParameters.count;
        if (![[tokens nextToken] isEqualTo: @"<"]) {
            return nil;
        }
        while (nTemplates--) {
            [ty.typeParameters addObject: [self parseType: tokens]];
            if (nTemplates > 0) {
                if (![[tokens nextToken] isEqualTo: @","]) {
                    return nil;
                }
            }
        }
        if (![[tokens nextToken] isEqualTo: @">"]) {
            return nil;
        }
    }
    while ([current = [tokens nextToken] isEqualTo: @"*"] || [current isEqualTo: @"&"]) {
        ty.indirectionCount++;
    }
    [tokens rewind];
    return ty;
}

-(TypeDefinition *)typeWithName: (NSString *)name
{
    for (TypeDefinition *defn in _types) {
        if ([defn.name isEqualTo: name]) {
            return defn;
        }
    }
    return nil;
}

- (NSUInteger) countCharacter: (NSString *) str containing: (NSString *) c
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern: [NSString stringWithFormat: @"%@", c]
                                                                         options: NSRegularExpressionCaseInsensitive
                                                                           error: nil];
    return [exp numberOfMatchesInString: str options: 0 range: NSMakeRange(0, [str length])];
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
