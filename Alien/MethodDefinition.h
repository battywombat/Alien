//
//  MethodDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//


#import <Foundation/Foundation.h>


#import "CPPTokenizer.h"
#import "TypeManager.h"

enum MethodType {
    INIT = 0,
    STATIC,
    INSTANCE,
    DESTRUCTOR
};

@interface MethodDefinition : NSObject

@property (readonly) enum MethodType type;
@property (readonly) NSArray<NSArray<NSString *> *> *arguments;
@property (readonly) NSString *name;
@property (readonly) NSString *returnType;

-(id)init: (NSString *) name withArguments: (NSArray<NSArray<NSString *> *> *) arguments ofType:(enum MethodType) type;
-(id)init: (NSString *) name returnType: (NSString *) returnType withArguments: (NSArray<NSArray<NSString *> *> *) arguments;
-(id)init: (NSString *) name;
-(id)init: (NSString *) name ofType: (enum MethodType) type;

@end
