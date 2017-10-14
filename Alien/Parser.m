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
    self.parserState.currentAccessLevel = PUBLIC;
    self.parserState.inClass = false;
    self.parserState.stub = false;
    return self;
}

-(id)initWithState: (NSMutableArray<ClassDefinition *> *) defns defines: (NSMutableDictionary<NSString *, NSString *> *) defines
{
    self = [super init];
    _tokens = nil;
    self.parserState.defns = defns;
    _defines = defines;
    self.parserState.currentAccessLevel = PUBLIC;
    self.parserState.inClass = false;
    self.parserState.stub = false;
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
            Parser *p = [[Parser alloc] initWithState: self.parserState.defns defines: _defines];
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
    _tokens = [[CPPTokenizer alloc] initFromString: str];
    [[TypeManager singleton] startNewFile];
    [_tokens filter: @"/*" to: @"*/"];
    [_tokens filter: @"//" to: @"\n"];
    while ([self parseDecl: _tokens]) {

    }
}

- (BOOL) parseDecl: (CPPTokenizer *) tokens
{
    NSString *currentToken = [_tokens nextToken];
    while ([currentToken isEqualTo: @"\n"]) {
        currentToken = [_tokens nextToken];
    }
    if (currentToken == nil) {
        return false;
    }
    if ([currentToken isEqualTo: @"#"]) {
        [self handlePreprocessorCommand];
    }
    else if (self.parserState.inClass) {
        [_tokens rewind];
        [self handleInClass];
    }
    else {
        if ([currentToken isEqualTo: @"class"]) {
            [self handleClassDefn];
        }
    }
    return true;
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
        [self parserState].inClass = false;
        [_tokens skipUntil: @";"];
    }
    else {
        [_tokens rewind];
        [self parseMethod: _tokens];
    }
}

- (NSArray<NSArray<NSString *> *> *)parseArgs
{
    NSMutableArray<NSArray<NSString *> *> *args = [[NSMutableArray alloc] init];
    NSArray<NSString *> *argument;
    NSString *currentToken;
    NSString *name;
    NSString *type;
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

- (void) parseMethod: (CPPTokenizer *)tokens
{
    NSString *returnType = [[TypeManager singleton] parseType: tokens];
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
    currentToken = [_tokens nextToken];
    [self parserState].inClass = true;
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
    ClassDefinition *current;
    for (int i = 0; i < [self.parserState.defns count]; i++) {
        current = [self.parserState.defns objectAtIndex: i];
        if ([[current className] isEqualTo: n.className]) {
            if ([current stub]) {
                [self.parserState.defns replaceObjectAtIndex: i withObject: n];
                return;
            }
        }
    }
}

- (void)throwException : (NSString *) message {
    @throw [NSException exceptionWithName: @"ParseError"
                                   reason: message
                                 userInfo: nil];
}

- (ParserState *)parserState {
    if (_states.count == 0) {
        [_states push: [[ParserState alloc] init]];
    }
    return [_states peek];
}

- (NSArray<ClassDefinition *> *)defns { 
    return self.parserState.defns;
}

@end
