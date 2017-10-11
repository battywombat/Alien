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

@interface MethodDefinition : NSObject
{
    BOOL isInit;
}

@property (setter=setStatic:, getter=isStatic) BOOL _static;

@property (getter=arguments) NSMutableArray<NSString *> *arguments;

@property (getter=name) NSString *methodName;

+(id)parseMethod: (CPPTokenizer *) s;

+(id)parseConstructor: (CPPTokenizer *) tokens;

-(id)init;

@end
