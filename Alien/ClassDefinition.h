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

enum AccessLevel {
    NONE = 0,
    PUBLIC,
    PRIVATE,
    PROTECTED
};

@interface ClassDefinition : NSObject

@property (readonly) NSString *className;
@property (readonly) NSArray<MethodDefinition *> *methods;
@property BOOL stub;

-(id)init: (NSString *) name withMethods: (NSArray *) methods;
-(id)init: (NSString *) name;


@end
