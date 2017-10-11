//
//  Parser.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Parser.h"

@implementation Parser

-(id)init
{
    self = [super init];
    in_line_comment = false;
    in_multiline_comment = false;
    in_preprocessor_command = false;
    tokens = nil;
    _defns = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) parseString: (NSString *) str
{
    tokens = [[CPPTokenizer alloc] initFromString: str];
    [[TypeManager singleton] startNewFile];
    NSString *currentToken;
    while ((currentToken = [tokens nextToken]) != nil) {
        if (in_line_comment) {
            if ([currentToken isEqualTo: @"\n"]) {
                in_line_comment = false;
            }
        }
        if (in_multiline_comment) {
            if ([currentToken isEqualTo: @"*/"]) {
                in_multiline_comment = false;
            }
        }
        if (in_preprocessor_command) {
            if ([currentToken isEqualTo: @"include"]) {
                NSString *includeFile = [[tokens nextToken] stringByReplacingOccurrencesOfString: @"\"" withString: @""];
                if ([includeFile isEqualTo: @"<"]) {
                    continue;
                }
                [self parseFile: includeFile];
            }
            if ([currentToken isEqualTo: @"\n"]) {
                in_preprocessor_command = false;
            }
        }
        if ([currentToken isEqualTo: @"class"]) {
            [self addClassDefn: [ClassDefinition parseClass: tokens]];
        }
        else if ([currentToken isEqualTo: @"//"]) {
            in_line_comment = true;
        }
        else if ([currentToken isEqualTo: @"/*"]) {
            in_multiline_comment = true;
        }
        else if ([currentToken isEqualTo: @"#"]) {
            in_preprocessor_command = true;
        }
    }
}

-(void) parseFile: (NSString *) file
{
    [self parseString: [NSString stringWithContentsOfFile: file usedEncoding: nil error: nil]];
}

-(void) addClassDefn: (ClassDefinition *) cls
{
    ClassDefinition *current;
    for (int i = 0; i < [_defns count]; i++) {
        current = [_defns objectAtIndex: i];
        if ([[current className] isEqualTo: [cls className]]) {
            if ([current isStub]) {
                [_defns replaceObjectAtIndex: i withObject: cls];
                return;
            }
        }
    }
}


@end
