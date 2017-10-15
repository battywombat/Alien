//
//  Parser.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"
#import "ClassDefinition.h"
#import "Stack.h"
#import "ParserState.h"
#import "TypeDefinition.h"

@interface Parser : NSObject
{
    @private
    Stack<ParserState *> *_states;
    CPPTokenizer *_tokens;
}

@property (readonly) NSMutableDictionary<NSString *, NSString *> *defines;
@property (readonly) NSMutableDictionary<NSString *, ClassDefinition *> *defns;

- (id) init;

- (void) parseFile: (NSString *) file;

- (void) parseString: (NSString *) str;

@end
