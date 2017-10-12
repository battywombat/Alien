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

@property (readonly) CPPTokenizer *tokens;
@property (readonly) NSMutableArray<ClassDefinition *> *defns;
@property (readonly) NSMutableDictionary<NSString *, NSString *> *defines;

-(id)init;

-(void) parseFile: (NSString *) file;

- (void) parseString: (NSString *) str;

- (void) addClassDefn: (ClassDefinition *) cls;

@end
