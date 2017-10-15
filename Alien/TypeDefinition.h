//
//  TypeDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/14/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeDefinition : NSObject

@property NSString *name;
@property NSString *containingNamespace;
@property NSMutableArray <TypeDefinition *> *typeParameters;
@property NSMutableArray <NSString *> *qualifiers;
@property NSUInteger indirectionCount;

-(id)init;

-(id)initWithName: (NSString *)name inNamespace: (NSString *) ns;
-(id)initWithName: (NSString *)name inNamespace: (NSString *) ns withParams: (NSUInteger) count;

+(TypeDefinition *) voidType;

+(TypeDefinition *) intType;

+(TypeDefinition *) charType;

+(TypeDefinition *) floatType;

+(TypeDefinition *) doubleType;

@end
