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
{
    BOOL in_line_comment;
    BOOL in_multiline_comment;
    BOOL in_preprocessor_command;
    CPPTokenizer *tokens;
}

@property (getter=defns)NSMutableArray<ClassDefinition *> *defns;

-(id)init;

-(void) parseFile: (NSString *) file;

- (void) parseString: (NSString *) str;

- (void) addClassDefn: (ClassDefinition *) cls;

@end
