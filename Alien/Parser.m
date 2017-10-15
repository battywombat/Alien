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
    _defines = [[NSMutableDictionary alloc] init];
    _defns = [[NSMutableDictionary alloc] init];
    _states = [[Stack alloc] init];
    return self;
}

-(id)initWithState: (NSMutableDictionary<NSString *, ClassDefinition *> *) defns defines: (NSMutableDictionary<NSString *, NSString *> *) defines
{
    self = [super init];
    _tokens = nil;
    _defines = [[NSMutableDictionary alloc] init];
    _states = [[Stack alloc] init];
    return self;
}

- (void)preprocessFile
{
    NSString *token;
    while ((token = [_tokens nextToken]) != nil) {
        if ([token isEqualTo: @"#"]) {
             [self handlePreprocessorCommand];
        }
    }
    [_tokens reset];
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
            Parser *p = [[Parser alloc] initWithState: _defns defines: _defines];
            [p parseFile: includeFile];
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
            int count = 1;
            while (true) {
                [_tokens skipUntil: @"#"];
                token = [_tokens nextToken];
                if ([token isEqualTo: @"ifdef"] || [token isEqualTo: @"ifndef"]) {
                    count++;
                }
                if ([token isEqualTo: @"endif"] || !token) {
                    count--;
                    if (count == 0) {
                        break;
                    }
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
    else if ([token isEqualTo: @"endif"]) {
        NSLog(@"Full stop");
    }
    [_tokens skipUntil: @"\n"];
}

-(void) parseString: (NSString *) str
{
    NSString *currentToken;
    _tokens = [[CPPTokenizer alloc] initFromString: str];
    [[TypeManager singleton] startNewFile];
    [_tokens filter: @"/*" to: @"*/"];
    [_tokens filter: @"//" to: @"\n"];
    [self preprocessFile];
    [_tokens filter: @"#" to: @"\n"];
    [_tokens removeAll: @"\n"];
    while ((currentToken = [_tokens nextToken]) != nil) {
        while ([currentToken isEqualTo: @"\n"]) {
            currentToken = [_tokens nextToken];
        }
        if ([currentToken isEqualTo: @"class"]) {
            [self handleClassDefn];
        }
        else if (self.parserState != nil) {
            [_tokens rewind];
            [self handleInClass];
        }
    }
}

-(void) parseFile: (NSString *) file
{
    [self parseString: [NSString stringWithContentsOfFile: file usedEncoding: nil error: nil]];
}

- (void)handleInClass {
    NSString *currentToken = [_tokens nextToken];
    if ([currentToken isEqualTo: @"public"]) {
        currentToken = [_tokens nextToken];
        if ([currentToken isEqualTo: @":"]) {
            self.parserState.currentAccessLevel = PUBLIC;
        }
        else {
            [self throwException: @"expected ':'"];
        }
    }
    else if ([currentToken isEqualTo: @"private"]) {
        currentToken = [_tokens nextToken];
        if ([currentToken isEqualTo: @":"]) {
            self.parserState.currentAccessLevel = PRIVATE;
        }
        else {
            [self throwException: @"Expected ':'"];
        }
    }
    else if ([currentToken isEqualTo: @"protected"]) {
        if ([currentToken isEqualTo: @":"]) {
            self.parserState.currentAccessLevel = PROTECTED;
        }
        else {
            [self throwException: @"Expected ':'"];
        }
    }
    else if ([currentToken isEqualTo: self.parserState.className]) { // Constructor
        NSArray<NSArray<NSString *> *> *args = [self parseArgs];
        [self.parserState.methods addObject: [[MethodDefinition alloc] init: self.parserState.className
                                              withArguments: args
                                                     ofType: INIT]];
        [_tokens skipUntil: @";"];
    }
    else if ([currentToken isEqualTo: [@"~" stringByAppendingString: self.parserState.className]]) { // Destructor
        [self.parserState.methods addObject: [[MethodDefinition alloc] init: [@"~" stringByAppendingString: self.parserState.className]
                                                     ofType: DESTRUCTOR]];
        [_tokens skipUntil: @";"];
    }
    else if ([currentToken isEqualTo: @"}"]) { // End of class
        [self addClassDefn];
        [_tokens skipUntil: @";"];
    }
    else {
        [_tokens rewind];
        [self parseMember: _tokens];
    }
}

- (NSArray<NSArray<NSString *> *> *)parseArgs
{
    NSMutableArray<NSArray<NSString *> *> *args = [[NSMutableArray alloc] init];
    NSArray *argument;
    NSString *currentToken;
    NSString *name;
    TypeDefinition *type;
    if (![[_tokens nextToken] isEqualTo: @"("]) {
        [self throwException: @"Expected '('"];
    }
    while (![currentToken = [_tokens nextToken] isEqualTo: @")"]) {
        [_tokens rewind];
        type = [[TypeManager singleton] parseType: _tokens];
        name = [_tokens nextToken];
        if ([name isEqualTo: @","]) {
            name = nil;
        }
        else {
            currentToken = [_tokens nextToken];
            if (![currentToken isEqualTo: @","]) {
                [_tokens rewind];
            }
        }
        argument = @[type, name];
        [args addObject: argument];
    }
    return args;
}

- (void) parseMember: (CPPTokenizer *)tokens
{
    TypeDefinition *returnType = [[TypeManager singleton] parseType: tokens];
    NSString *name = [_tokens nextToken];
    if ([[_tokens nextToken] isEqualTo: @";"]) { // This is a field
        return;
    }
    [_tokens rewind];
    NSArray<NSArray<NSString *> *> *args = [self parseArgs];
    [self.parserState.methods addObject: [[MethodDefinition alloc] init: name
                                             returnType: returnType
                                          withArguments: args]];
    [_tokens skipUntil: @";"];
}

- (void)handleClassDefn {
    NSString *currentToken;
    [_states push: [[ParserState alloc] init]];
    self.parserState.className = [_tokens nextToken];
    NSString *superClassName;
    currentToken = [_tokens nextToken];
    if ([currentToken isEqualTo: @":"]) {
        superClassName = [_tokens nextToken];
    }
    else if ([currentToken isEqualTo: @";"]) {
        self.parserState.stub = true;
        [self addClassDefn];
        return;
    }
    else {
        superClassName = @"NSObject";
    }
    self.parserState.stub = false;
//    currentToken = [_tokens nextToken];
}

-(void) addClassDefn
{
    ClassDefinition *n;
    if (self.parserState.stub) {
        n = [[ClassDefinition alloc] init: self.parserState.className];
    }
    else {
        n = [[ClassDefinition alloc] init: self.parserState.className withMethods: self.parserState.methods];
    }
    if (_defns[n.name] == nil || _defns[n.name].stub) {
        _defns[n.name] = n;
    }
    [_states pop];
}

- (void)throwException : (NSString *) message {
    @throw [NSException exceptionWithName: @"ParseError"
                                   reason: message
                                 userInfo: nil];
}

- (ParserState *)parserState {
    if (_states.count == 0) {
        return nil;
    }
    return [_states peek];
}

@end
