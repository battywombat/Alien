//
//  MethodDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//


#import <Foundation/Foundation.h>


#import "CPPTokenizer.h"
#import "Type.h"
#import "FieldDefinition.h"


enum MethodType {
    INIT = 0,
    STATIC,
    INSTANCE,
    DESTRUCTOR
};

@interface MethodDefinition : FieldDefinition

@property (readonly) enum MethodType methodType;
@property (readonly) NSArray<NSArray *> *arguments;
@property BOOL isVirtual;

-(id)init: (NSString *) name withArguments: (NSArray<NSArray *> *) arguments ofType:(enum MethodType) type withAccessLevel: (enum AccessLevel) accessLevel;
-(id)init: (NSString *) name returnType: (Type *) returnType withArguments: (NSArray<NSArray *> *) arguments withAccessLevel: (enum AccessLevel) accessLevel;
-(id)init: (NSString *) name ofType: (enum MethodType) type withAccessLevel: (enum AccessLevel) accessLevel;

@end
