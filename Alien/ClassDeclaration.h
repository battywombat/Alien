//
//  ClassDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"
#import "TypeManager.h"
#import "MethodDefinition.h"
#import "TypeDeclaration.h"

enum AccessLevel {
    NONE = 0,
    PUBLIC,
    PRIVATE,
    PROTECTED
};

@interface ClassDeclaration : TypeDeclaration

@property (readonly) NSArray<MethodDefinition *> *methods;
@property (readonly) NSArray<NSArray *> *fields;
@property BOOL stub;

-(id)init: (NSString *) name withMethods: (NSArray *) methods andFields: (NSArray<NSArray *> *) fields;
-(id)init: (NSString *) name;


@end
