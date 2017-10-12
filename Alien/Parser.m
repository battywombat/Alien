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
    _tokens = nil;
    _defns = [[NSMutableArray alloc] init];
    _defines = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)handlePreprocessorCommand
{
    NSString *token = [_tokens nextToken];
    if ([token isEqualTo: @"include"]) {
        NSString *includeFile = [[_tokens nextToken] stringByReplacingOccurrencesOfString: @"\"" withString: @""];
        if (![includeFile isEqualTo: @"<"]) {
            if (![NSFileManager.defaultManager fileExistsAtPath: includeFile]) {
                @throw [NSException exceptionWithName: @"ParseError"
                                               reason: [NSString stringWithFormat: @"include file %@ not found", includeFile]
                                             userInfo: nil];
            }
            [self parseFile: includeFile];
        }
    }
    else if ([token isEqualTo: @"define"]) {
        NSString *defname = [_tokens nextToken], *value = [_tokens nextToken];
        if (_defines[defname] != nil) {
            @throw [NSException exceptionWithName: @"ParseError"
                                           reason: [NSString stringWithFormat: @"%@ defined twice", defname]
                                         userInfo: nil];
        }
        if (!defname || [defname isEqualTo: @"\n"]) {
            [_tokens rewind];
        }
        else {
            _defines[defname] = !value || [value isEqualTo: @"\n"] ? @"" : value;
        }
    }
    else if ([token isEqualTo: @"ifdef"]) {
        token = [_tokens nextToken];
        if (token && _defines[token] == nil) {
            while (true) {
                [_tokens skipUntil: @"#"];
                if ([token = [_tokens nextToken] isEqualTo: @"endif"] || !token) {
                    break;
                }
            }
        }
    }
    else if ([token isEqualTo: @"ifndef"]) {
        token = [_tokens nextToken];
        if (token && _defines[token] != nil) {
            while (true) {
                [_tokens skipUntil: @"#"];
                if ([token = [_tokens nextToken] isEqualTo: @"endif"] || !token) {
                    break;
                }
            }
        }
    }
    [_tokens skipUntil: @"\n"];
}

-(void) parseString: (NSString *) str
{
    _tokens = [[CPPTokenizer alloc] initFromString: str];
    [[TypeManager singleton] startNewFile];
    NSString *currentToken;
    while ((currentToken = [_tokens nextToken]) != nil) {
        if ([currentToken isEqualTo: @"class"]) {
            [self addClassDefn: [[ClassDefinition alloc] initWithTokens: _tokens]];
        }
        else if ([currentToken isEqualTo: @"//"]) {
            [_tokens skipUntil: @"\n"];
        }
        else if ([currentToken isEqualTo: @"/*"]) {
            [_tokens skipUntil: @"*/"];
        }
        else if ([currentToken isEqualTo: @"#"]) {
            [self handlePreprocessorCommand];
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
            if ([current stub]) {
                [_defns replaceObjectAtIndex: i withObject: cls];
                return;
            }
        }
    }
}


@end
