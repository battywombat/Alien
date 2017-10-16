//
//  ParserTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/9/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Parser.h"

@interface ParserTests : XCTestCase

@property Parser *parser;

@end

static NSString *classdefn = @"class A {\n%@\n};";

@implementation ParserTests

- (void) setUp {
    [super setUp];
    _parser = [[Parser alloc] init];
}

- (void)testParseEmptyString {
    XCTAssertNoThrow([_parser parseString: @""]);
}

- (void)testDoesntParseLineComment {
    [_parser parseString: @"// class Test {}; \n"];
    XCTAssert([[_parser defns] count] == 0, @"Should not have parsed class");
}

- (void)testDefine {
    [_parser parseString: @"#define TEST 5"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @"5"], @"Define Not Parsed");
}

- (void)testEmptyDefine {
    [_parser parseString: @"#define TEST"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @""]);
}

- (void)testIfdefSkips {
    [_parser parseString: @"#ifdef TEST\n #define TEST #endif"];
    XCTAssert([_parser defines][@"TEST"] == nil);
}

- (void)testIfdefNotSkips {
    [_parser parseString: @"#define TEST 5\n#ifdef TEST\n #define TEST2 \n#endif"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @"5"] && [_parser.defines[@"TEST2"] isEqualTo: @""]);
}

- (void)testDefineTwice {
    XCTAssertThrows([_parser parseString: @"#define TEST 5\n#define TEST 3"]);
}

- (void)testInvalidInclude {
    XCTAssertThrows([_parser parseString: @"#include \"fake\"\n"]);
}

-(void)testDefineLastLine {
    XCTAssertNoThrow([_parser parseString: @"#define A 5"]);
}

- (void)testNestedDefine {
    [_parser parseString:
     @"#ifdef A\n"
     @"#ifndef B\n"
     @"#endif"
     @"#define C\n"
     @"#endif"];
    XCTAssert([_parser defines][@"C"] == nil);
}

- (void)testParseMethod {
    MethodDefinition *m;
    [_parser parseString: [NSString stringWithFormat: classdefn, @"std::string\n dothing();"]];
    m = _parser.defns[@"A"].methods[0];
    XCTAssert([m.type.typeDecl.name isEqualTo: @"string"] && [m.type.typeDecl.containingNamespace isEqualTo: @"std"]);
    XCTAssert(m.arguments.count == 0);
    XCTAssert([m.name isEqualTo: @"dothing"]);
}

- (void)testNestedClass {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"class B {};"]];
    XCTAssert([_parser defns].count == 2);
}

- (void)testContainingPointer {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A *_child;"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil);
    XCTAssert([c.name isEqualTo: @"A"]);
    XCTAssert([c.fields count] == 1);
}

- (void)testSameReturnType {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A something();"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert([m.type.typeDecl.name isEqualTo: @"A"]);
    XCTAssert([m.name isEqualTo: @"something"]);
    XCTAssert(m.arguments.count == 0);
}

- (void)testSameFieldType {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A _something;"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.fields.count == 1);
    FieldDefinition *m = c.fields[0];
    XCTAssert([m.type.typeDecl.name isEqualTo: @"A"]);
    XCTAssert([m.name isEqualTo: @"_something"]);
}

- (void)testConstructorEmptyArgs {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A();"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
}

- (void)testConstructorWithArgs {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A(int a, std::string b);"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
    XCTAssert(m.arguments.count == 2);
}

- (void)testConstructorWithArgsNoNames {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A(int, std::string);"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
    XCTAssert(m.arguments.count == 2);
}

- (void)testMultipleFieldsSameLine {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A(int, std::string); int *_f;"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
    XCTAssert(m.arguments.count == 2);
    XCTAssert(c.fields.count == 1);
    FieldDefinition *field = c.fields[0];
    XCTAssert([field.name isEqualTo: @"_f"]);
    XCTAssert(field.type.indirectionCount == 1);
    XCTAssert([field.type.typeDecl.name isEqualTo: @"int"]);
}

- (void)testMultipleFieldsTwoLines {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"A(int, std::string);\n int *_f;"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
    XCTAssert(m.arguments.count == 2);
    XCTAssert(c.fields.count == 1);
    FieldDefinition *field = c.fields[0];
    XCTAssert([field.name isEqualTo: @"_f"]);
    XCTAssert(field.type.indirectionCount == 1);
    XCTAssert([field.type.typeDecl.name isEqualTo: @"int"]);
}

- (void) testAccesSpecifiers {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"public: A(int);\n private: int *_f;"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == INIT);
    XCTAssert(m.arguments.count == 1);
    XCTAssert(m.accessLevel == PUBLIC);
    XCTAssert(c.fields.count == 1);
    FieldDefinition *field = c.fields[0];
    XCTAssert([field.name isEqualTo: @"_f"]);
    XCTAssert(field.type.indirectionCount == 1);
    XCTAssert([field.type.typeDecl.name isEqualTo: @"int"]);
    XCTAssert(field.accessLevel == PRIVATE);
}

- (void) testDestructor {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"~A();"]];
    ClassDeclaration *c = _parser.defns[@"A"];
    XCTAssert(c != nil && c.methods.count == 1);
    MethodDefinition *m = c.methods[0];
    XCTAssert(m.methodType == DESTRUCTOR);
}



@end
