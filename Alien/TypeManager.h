//
//  TypeManager.h
//  Alien
//
//  Created by Paul Warner on 10/7/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"
#import "TypeDefinition.h"

@interface TypeManager : NSObject

@property (readonly) NSMutableDictionary<NSString *, NSArray<TypeDefinition *> *> *basicNamespaces;

@property (readonly) NSMutableArray<TypeDefinition *> *basicTypes;

@property (readonly) NSMutableDictionary<NSString *, NSArray<TypeDefinition *> *> *namespaces;

@property (readonly) NSArray<NSString *> *qualifiers;

@property (readonly) NSMutableArray<TypeDefinition *> *types;

- (id)init;

- (TypeDefinition *)parseType: (CPPTokenizer *) tokens;

- (void) startNewFile;

- (void) useNamespace: (NSString *)ns;

- (void) addNamespace: (NSString *)ns;


@end
