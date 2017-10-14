//
//  TypeManager.h
//  Alien
//
//  Created by Paul Warner on 10/7/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"

@interface TypeManager : NSObject

@property (getter=basicNamespaces) NSMutableDictionary<NSString *, NSArray<NSString *> *> *basicNamespaces;

@property (getter=basicTypes) NSMutableArray<NSString *> *basicTypes;

@property (getter=namespaces) NSMutableDictionary<NSString *, NSArray<NSString *> *> *namespaces;

@property (getter=qualifiers) NSArray<NSString *> *qualifiers;

@property (getter=types) NSMutableArray<NSString *> *types;

+ (TypeManager *)singleton;

- (id)init;

- (NSString *)parseType: (CPPTokenizer *) tokens;

- (void) startNewFile;

- (void) useNamespace: (NSString *)ns;

- (void) addNamespace: (NSString *)ns;


@end
