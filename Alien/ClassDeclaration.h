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

@interface ClassDeclaration : TypeDeclaration

@property (readonly) NSArray<MethodDefinition *> *methods;
@property (readonly) NSArray<FieldDefinition *> *fields;
@property BOOL stub;

-(id)init: (NSString *) name withMethods: (NSArray *) methods andFields: (NSArray<FieldDefinition *> *) fields;
-(id)init: (NSString *) name;


@end
