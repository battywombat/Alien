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
                                                  @"std" : @[ @"string", @"vector" ]
                                                  }];
    _basicTypes = [[NSMutableArray alloc] init];
    _qualifiers = @[ @"short", @"long", @"unsigned" ];
    [_basicTypes addObjectsFromArray: @[ @"int", @"char", @"float", @"double" ]];
    return self;
}

-(NSString *)parseType: (CPPTokenizer *) tokens
{
    NSString *ty;
    NSString *current = [tokens nextToken];
    NSArray<NSString *> *nsContents = [self namespaces][current];
    if (nsContents != nil) {
        if (![@"::" isEqualTo: [tokens nextToken]]) {
            return nil;
        }
        NSString *subType = [tokens nextToken];
        if (![nsContents containsObject: subType]) {
            return nil;
        }
        ty = [NSString stringWithFormat: @"%@::%@", current, subType];
    }
    else if ([[self qualifiers] containsObject: current]) {
        ty = current;
        while ([[self qualifiers] containsObject: current = [tokens nextToken]]) {
            ty = [ty stringByAppendingString: [NSString stringWithFormat: @" %@", current]];
        }
        ty = [ty stringByAppendingString: [NSString stringWithFormat: @" %@", current]];
    }
    else if ([[self types] containsObject: current]) {
        ty = current;
    }
    else {
        @throw [NSException exceptionWithName: @"Syntax Error"
                                       reason: [NSString stringWithFormat: @"Invalid type %@", current]
                                     userInfo: nil];
    }
    while ([current = [tokens nextToken] isEqualTo: @"*"] || [current isEqualTo: @"&"]) {
        ty = [NSString stringWithFormat: @"%@ %@", ty, current];
    }
    [tokens rewind];
    return ty;
}

-(void) startNewFile
{
    _types = [[self basicTypes] mutableCopy];
    _namespaces = [[self basicNamespaces] mutableCopy];
}

- (void) useNamespace: (NSString *)ns
{
    NSArray<NSString *> *arr = [self namespaces][ns];
    if (ns == nil) {
        NSException *exception = [NSException
                                  exceptionWithName: @"InvalidNamespaceException"
                                  reason: [NSString stringWithFormat: @"invalid namespace %@", ns]
                                  userInfo: nil];
        @throw exception;
    }
    [_types addObjectsFromArray: arr];
}

- (void) addNamespace: (NSString *)ns
{
    if ([self namespaces][ns] == nil) {
        return;
    }
    _namespaces[ns] = [[NSMutableArray alloc] init];
}

@end
