//
//  MethodDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//


#import <Foundation/Foundation.h>


#import "CPPTokenizer.h"
#import "TypeDefinition.h"

enum MethodType {
    INIT = 0,
    STATIC,
    INSTANCE,
    DESTRUCTOR
};

@interface MethodDefinition : NSObject

@property (readonly) enum MethodType type;
@property (readonly) NSArray<NSArray *> *arguments;
@property (readonly) NSString *name;
@property (readonly) TypeDefinition *returnType;

-(id)init: (NSString *) name withArguments: (NSArray<NSArray *> *) arguments ofType:(enum MethodType) type;
-(id)init: (NSString *) name returnType: (TypeDefinition *) returnType withArguments: (NSArray<NSArray *> *) arguments;
-(id)init: (NSString *) name;
-(id)init: (NSString *) name ofType: (enum MethodType) type;

@end
