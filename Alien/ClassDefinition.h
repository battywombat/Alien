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

@interface ClassDefinition : NSObject
{
    NSString *className;
}

@property (getter=methods) NSMutableArray<MethodDefinition *> *methods;
@property (getter=isStub, setter=setStub:) BOOL stub;

-(id)init;

+(id)parseClass: (CPPTokenizer *) tokens;


@end
