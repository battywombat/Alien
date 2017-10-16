//
//  ParserState.h
//  Alien
//
//  Created by Paul Warner on 10/13/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassDeclaration.h"
#import "MethodDefinition.h"

@interface ParserState : NSObject

@property BOOL inClass;
@property BOOL stub;
@property enum AccessLevel currentAccessLevel;
@property NSMutableArray <MethodDefinition *> *methods;
@property NSString *className;

-(id) init;

@end
