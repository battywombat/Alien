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
    _currentAccessLevel = PUBLIC;
    _inClass = false;
    _stub = false;
    return self;
}

-(id)initWithState: (NSMutableArray<ClassDefinition *> *) defns defines: (NSMutableDictionary<NSString *, NSString *> *) defines
{
    self = [super init];
    _tokens = nil;
    _defns = defns;
    _defines = defines;
    _currentAccessLevel = PUBLIC;
    _inClass = false;
    _stub = false;
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
    else if (_inClass) {
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
            _currentAccessLevel = PUBLIC;
        }
        else {
            [self throwException: @"expected ':'"];
        }
    }
    else if ([currentToken isEqualTo: @"private"]) {
        currentToken = [_tokens nextToken];
        if ([currentToken isEqualTo: @":"]) {
            _currentAccessLevel = PRIVATE;
        }
        else {
            [self throwException: @"Expected ':'"];
        }
    }
    else if ([currentToken isEqualTo: @"protected"]) {
        if ([currentToken isEqualTo: @":"]) {
            _currentAccessLevel = PROTECTED;
        }
        else {
            [self throwException: @"Expected ':'"];
        }
    }

    else if ([currentToken isEqualTo: _className]) { // Constructor
        NSArray<NSArray<NSString *> *> *args = [self parseArgs];
        [_methods addObject: [[MethodDefinition alloc] init: _className
                                              withArguments: args
                                                     ofType: INIT]];
        [_tokens skipUntil: @";"];
    }
    else if ([currentToken isEqualTo: [@"~" stringByAppendingString: _className]]) { // Destructor
        [_methods addObject: [[MethodDefinition alloc] init: [@"~" stringByAppendingString: _className]
                                                     ofType: DESTRUCTOR]];
        [_tokens skipUntil: @";"];
    }
    else if ([currentToken isEqualTo: @"}"]) { // End of class
        [self addClassDefn];
        _inClass = false;
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
    [_methods addObject: [[MethodDefinition alloc] init: name
                                             returnType: returnType
                                          withArguments: args]];
    [_tokens skipUntil: @";"];
}

- (void)handleClassDefn {
    NSString *currentToken;
    _methods = [[NSMutableArray alloc] init];
    _className = [_tokens nextToken];
    NSString *superClassName;
    currentToken = [_tokens nextToken];
    if ([currentToken isEqualTo: @":"]) {
        superClassName = [_tokens nextToken];
    }
    else if ([currentToken isEqualTo: @";"]) {
        _stub = true;
        [self addClassDefn];
        return;
    }
    else {
        superClassName = @"NSObject";
    }
    _stub = false;
    currentToken = [_tokens nextToken];
    _inClass = true;
}

-(void) addClassDefn
{
    ClassDefinition *n;
    if (_stub) {
        n = [[ClassDefinition alloc] init: _className];
    }
    else {
        n = [[ClassDefinition alloc] init: _className withMethods: _methods];
    }
    ClassDefinition *current;
    for (int i = 0; i < [_defns count]; i++) {
        current = [_defns objectAtIndex: i];
        if ([[current className] isEqualTo: n.className]) {
            if ([current stub]) {
                [_defns replaceObjectAtIndex: i withObject: n];
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

@end
