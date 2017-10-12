//
//  CPPTokenizer.m
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"

@implementation CPPTokenizer

-(id)initFromString: (NSString *) s
{
    prev = -1;
    data = s;
    inLineComment = false;
    inMultilineComment = false;
    op_was_last = false;
    return self;
}

-(id)initFromFile: (NSString *) fp
{
    return [self initFromString: [NSString stringWithContentsOfFile: fp usedEncoding: nil error: nil]];
}

-(NSString *)nextToken
{
    NSString *tok;
    int symlen;
    NSMutableCharacterSet *operators = [[NSMutableCharacterSet alloc] init];
    [operators addCharactersInString: @"()[];~%^{}."];
    NSMutableCharacterSet *symbols = [[NSMutableCharacterSet alloc] init];
    [symbols addCharactersInString: @"_"];
    [symbols formUnionWithCharacterSet: [NSCharacterSet alphanumericCharacterSet]];
    if (i == [data length]) {
        return nil;
    }
    while ([[NSCharacterSet whitespaceCharacterSet] characterIsMember: [data characterAtIndex: i]]) {
        i++;
    }
    if ([data characterAtIndex: i] == L'/') {
        symlen = [self getSymLength: @"/*"];
        if ([data characterAtIndex: i+1] == L'*') {
            inMultilineComment = true;
        }
        else if ([data characterAtIndex: i+1] == L'/') {
            inLineComment = true;
        }
    }
    else if ([data characterAtIndex: i] == L'*') {
        symlen = [self getSymLength: @"/"];
        if (symlen > 0) {
            inMultilineComment = false;
        }
    }
    else if ([data characterAtIndex: i] == L'\n') {
        symlen = 1;
        linenum += 1;
        colnum = 0;
        inMultilineComment = false;
    }
    else if ([data characterAtIndex: i] == L'=') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: i] == L'|') {
        symlen = [self getSymLength: @"|"];
    }
    else if ([data characterAtIndex: i] == L'+') {
        symlen = [self getSymLength: @"+"];
    }
    else if ([data characterAtIndex: i] == L'-') {
        symlen = [self getSymLength: @"-"];
    }
    else if ([data characterAtIndex: i] == L'!') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: i] == L':') {
        symlen = [self getSymLength: @":"];
    }
    else if ([data characterAtIndex: i] == L'&') {
        symlen = [self getSymLength: @"&"];
    }
    else if ([data characterAtIndex: i] == L'<') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: i] == L'>') {
        symlen = [self getSymLength: @"="];
    }
    else if ([operators characterIsMember: [data characterAtIndex: i]]) {
        symlen = 1;
        op_was_last = true;
    }
    else if ([data characterAtIndex: i] == L'"') {
        NSMutableCharacterSet *s = [[NSMutableCharacterSet alloc] init];
        [s addCharactersInString: @"\""];
        symlen = [self getSymLengthExculdingSet: s] + 1;
        op_was_last = false;
    }
    else if ([[NSCharacterSet letterCharacterSet] characterIsMember: [data characterAtIndex: i]] || [data characterAtIndex: i] == L'_') {
        symlen = [self getSymLengthInSet: symbols exculding: nil];
        op_was_last = false;
    }
    else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: [data characterAtIndex: i]]) {
        op_was_last = false;
        symlen = [self getSymLengthInSet: [NSCharacterSet decimalDigitCharacterSet] exculding: [NSCharacterSet letterCharacterSet]];
    }    else {
        [self throwException: i];
        symlen = 1;
    }
    tok = [data substringWithRange: NSMakeRange(i, symlen)];
    prev = i;
    i += symlen;
    colnum += i;
    return tok;
}

-(void)throwException: (int) i
{
    NSException *exception = [NSException
                              exceptionWithName: @"InvalidSyntaxException"
                              reason: [NSString stringWithFormat: @"invalid symbol %c at line: %d col %d", [data characterAtIndex: i], linenum, colnum]
                              userInfo: nil];
    @throw exception;
}

-(int)getSymLength: (NSString *)next
{
    if (op_was_last && !inLineComment && !inMultilineComment) {
        [self throwException: i+1];
    }
    NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
    [set addCharactersInString: next];
    op_was_last = true;
    return i < [data length] - 1 && [set characterIsMember: [data characterAtIndex: i+1]] ? 2 : 1;
}

-(int)getSymLengthInSet: (NSCharacterSet *)set exculding: (NSCharacterSet *)exclude
{
    int len = 1;
    while (i+len < [data length] && [set characterIsMember: [data characterAtIndex: i+len]]) {
        len++;
    }
    if (exclude != nil && i+len < [data length] && [exclude characterIsMember: [data characterAtIndex: i+len]]) {
        [self throwException: i+len];
    }
    return len;
}

-(int)getSymLengthExculdingSet: (NSCharacterSet *)set
{
    int len = 1;
    while (i+len < [data length] && ![set characterIsMember: [data characterAtIndex: i+len]]) {
        len++;
    }
    return len;
}

-(void)rewind
{
    if (prev != -1) {
        i = prev;
    }
}

@end
