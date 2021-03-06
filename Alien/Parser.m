//
//  Parser.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Parser.h"
#import "TypeDeclaration.h"

@implementation Parser

-(id)init
{
    return [self initWithState: [[NSMutableDictionary alloc] init] defines: [[NSMutableDictionary alloc] init]];
}

-(id)initWithState: (NSMutableDictionary<NSString *, ClassDeclaration *> *) defns defines: (NSMutableDictionary<NSString *, NSString *> *) defines
{
    self = [super init];
    _tokens = nil;
    _defines = [[NSMutableDictionary alloc] init];
    _states = [[Stack alloc] init];
    _defns = defns;
    _defines = defines;
    _types = [[TypeManager alloc] init];
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
    [_types startNewFile];
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
            [self parseClassDecl];
        }
    }
}

-(void) parseFile: (NSString *) file
{
    [self parseString: [NSString stringWithContentsOfFile: file usedEncoding: nil error: nil]];
}

- (void)parseClassDecl {
    NSString *currentToken;
    NSString *spec = [_tokens nextToken];
    BOOL isVirtual = false, isStatic = false;
    if ([spec isEqualTo: @"virtual"]) {
        isVirtual = true;
    }
    else if ([spec isEqualTo: @"static"]) {
        isStatic = true;
    }
    else {
        [_tokens rewind];
    }
    Type *ty = [_types parseType: _tokens];
    if (ty == nil) {
        currentToken = [_tokens nextToken];
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
        else if ([currentToken isEqualTo: @"}"]) { // End of class
            [self addClassDefn];
            [_tokens skipUntil: @";"];
        }
        else if ([currentToken isEqualTo: @"~"])  {
            if (![[_tokens nextToken] isEqualTo: self.parserState.className]) {
                [self throwException: [NSString stringWithFormat: @"Destructor Error: Expected %@", self.parserState.className]];
            }
            NSArray *args = [self parseArgs];
            if (args.count != 0) {
                [self throwException: @"Destructor should have no arguments"];
            }
            if (![[_tokens nextToken] isEqualTo: @";"]) {
                [self throwException: @"Expected ';'"];
            }
            MethodDefinition *d = [[MethodDefinition alloc] init: [@"~" stringByAppendingString: self.parserState.className]
                                                          ofType: DESTRUCTOR
                                                 withAccessLevel: self.parserState.currentAccessLevel];
            d.isVirtual = isVirtual;
            [self.parserState.methods addObject: d];
        }
        else {
            [self throwException: [NSString stringWithFormat: @"Unrecognized token: %@", currentToken]];
        }

    }
    else {
        currentToken = [_tokens nextToken];
        if ([currentToken isEqualTo: @"("] && [ty.typeDecl.name isEqualTo: self.parserState.className] && !ty.isReference && ty.indirectionCount == 0) { // Constructor
            if (isVirtual || isStatic) {
                [self throwException: @"Constructor cannot be static or virtual"];
            }
            [_tokens rewind];
            NSArray<NSArray<NSString *> *> *args = [self parseArgs];
            [self.parserState.methods addObject: [[MethodDefinition alloc] init: self.parserState.className
                                                                  withArguments: args
                                                                         ofType: INIT
                                                                withAccessLevel: self.parserState.currentAccessLevel]];
            [_tokens skipUntil: @";"];
        }
        else {
            [_tokens rewind];
            [self parseMember: ty isVirtual: isVirtual isStatic: isStatic];
        }
    }
}

- (NSArray<NSArray<NSString *> *> *)parseArgs
{
    NSMutableArray<NSArray<NSString *> *> *args = [[NSMutableArray alloc] init];
    NSArray *argument;
    NSString *currentToken;
    NSString *name;
    Type *type;
    NSString *t = [_tokens nextToken];
    if (![t isEqualTo: @"("]) {
        [self throwException: @"Expected '('"];
    }
    while (![currentToken = [_tokens nextToken] isEqualTo: @")"]) {
        [_tokens rewind];
        type = [_types parseType: _tokens];
        name = [_tokens nextToken];
        if ([name isEqualTo: @","] || [name isEqualTo: @")"]) {
            if ([name isEqualTo: @")"]) {
                [_tokens rewind];
            }
            name = @"";
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

- (void) parseMember: (Type *) ty isVirtual: (BOOL) isVirtual isStatic: (BOOL) isStatic
{
    NSString *name = [_tokens nextToken];
    if ([[_tokens nextToken] isEqualTo: @";"]) { // This is a field
        if (isVirtual) {
            [self throwException: @"Field cannot be virtual"];
        }
        FieldDefinition *field = [[FieldDefinition alloc] initWithName: name andType: ty andAccessLevel: self.parserState.currentAccessLevel];
        field.isStatic = isStatic;
        [self.parserState.fields addObject: field];
        return;
    } // Otherwise, must be method
    if (isVirtual && isStatic) {
        [self throwException: @"Method cannot be both virtual and static"];
    }
    [_tokens rewind];
    NSArray<NSArray<NSString *> *> *args = [self parseArgs];
    MethodDefinition *d = [[MethodDefinition alloc] init: name
                                              returnType: ty
                                           withArguments: args
                                         withAccessLevel: self.parserState.currentAccessLevel];
    d.isVirtual = isVirtual;
    d.isStatic = isStatic;
    if (![[_tokens nextToken] isEqualTo: @";"]) {
        [self throwException: @"Expected ';'"];
    }
    [self.parserState.methods addObject: d];
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
    [_types.types addObject: [[ClassDeclaration alloc] initWithName: self.parserState.className inNamespace: nil]];
}

-(void) addClassDefn
{
    ClassDeclaration *n;
    if (self.parserState.stub) {
        n = [[ClassDeclaration alloc] init: self.parserState.className];
    }
    else {
        n = [[ClassDeclaration alloc] init: self.parserState.className withMethods: self.parserState.methods andFields: self.parserState.fields];
    }
    if (_defns[n.name] == nil || _defns[n.name].stub) {
        _defns[n.name] = n;
    }
    [_types addType: n];
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
