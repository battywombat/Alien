//
//  Parser.h
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"
#import "ClassDeclaration.h"
#import "Stack.h"
#import "ParserState.h"
#import "Type.h"

@interface Parser : NSObject
{
    @private
    Stack<ParserState *> *_states;
    CPPTokenizer *_tokens;
    TypeManager *_types;
    NSArray<NSArray *> *_fields;
}

@property (readonly) NSMutableDictionary<NSString *, NSString *> *defines;
@property (readonly) NSMutableDictionary<NSString *, ClassDeclaration *> *defns;

- (id) init;

- (void) parseFile: (NSString *) file;

- (void) parseString: (NSString *) str;

@end
