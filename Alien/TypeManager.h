//
//  TypeManager.h
//  Alien
//
//  Created by Paul Warner on 10/7/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"
#import "Type.h"
#import "TypeDeclaration.h"
#import "ClassDeclaration.h"

@class ClassDeclaration;

@interface TypeManager : NSObject

@property (readonly) NSMutableDictionary<NSString *, NSArray<TypeDeclaration *> *> *basicNamespaces;

@property (readonly) NSMutableArray<TypeDeclaration *> *basicTypes;

@property (readonly) NSMutableDictionary<NSString *, NSArray<TypeDeclaration *> *> *namespaces;

@property (readonly) NSArray<NSString *> *qualifiers;

@property (readonly) NSMutableArray<TypeDeclaration *> *types;

- (id)init;

- (Type *)parseType: (CPPTokenizer *) tokens;

- (void) startNewFile;

- (void) useNamespace: (NSString *)ns;

- (void) addNamespace: (NSString *)ns;

- (void) addType: (ClassDeclaration *) ty;

- (void) generateConversions;

@end
