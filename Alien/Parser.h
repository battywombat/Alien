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

@interface Parser : NSObject

@property (readonly) BOOL inClass;
@property (readonly) BOOL stub;
@property (readonly) CPPTokenizer *tokens;
@property (readonly) NSMutableArray<ClassDefinition *> *defns;
@property (readonly) NSMutableDictionary<NSString *, NSString *> *defines;
@property (readonly) NSMutableArray <MethodDefinition *> *methods;
@property (readonly) NSString *className;

- (id) init;

- (void) parseFile: (NSString *) file;

- (void) parseString: (NSString *) str;

- (void) handleClassSymbol;

@end
