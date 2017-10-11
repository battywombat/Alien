//
//  MethodDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MethodDefinition.h"

@implementation MethodDefinition

@synthesize arguments = _arguments;

@synthesize methodName = _name;

-(id)init
{
    self = [super init];
    _arguments = [[NSMutableArray alloc] init];
    _name = nil;
    
    return self;
}

+(id)parseMethod: (CPPTokenizer *) tokens
{
    MethodDefinition *d = [[MethodDefinition alloc] init];
//    NSString *returnType = [[TypeManager singleton] parseType: tokens];
//    NSString *name = [tokens nextToken];
    NSString *currentToken = [tokens nextToken];
    if (![currentToken isEqualTo: @"("]) {
        
    }
    return d;
}

+(id)parseConstructor: (CPPTokenizer *) tokens
{
    MethodDefinition *d = [[MethodDefinition alloc] init];
    [d setStatic: true];
    NSString *currentToken = [tokens nextToken];
    if (![currentToken isEqualTo: @"("]) {
        return d;
    }
    while (![currentToken isEqualTo: @")"]) {
        
    }
    
    if (![currentToken isEqualTo: @";"]) {
        return d;
    }
    
    
    return d;
}

@end
