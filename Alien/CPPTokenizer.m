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
    opWasLast = false;
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
    if (idx == [data length]) {
        return nil;
    }
    while ([[NSCharacterSet whitespaceCharacterSet] characterIsMember: [data characterAtIndex: idx]]) {
        idx++;
    }
    if ([data characterAtIndex: idx] == L'/') {
        symlen = [self getSymLength: @"/*"];
        if ([data characterAtIndex: idx+1] == L'*') {
            inMultilineComment = true;
        }
        else if ([data characterAtIndex: idx+1] == L'/') {
            inLineComment = true;
        }
    }
    else if ([data characterAtIndex: idx] == L'*') {
        symlen = [self getSymLength: @"/"];
        if (symlen > 0) {
            inMultilineComment = false;
        }
    }
    else if ([data characterAtIndex: idx] == L'\n') {
        symlen = 1;
        linenum += 1;
        colnum = 0;
        inMultilineComment = false;
    }
    else if ([data characterAtIndex: idx] == L'=') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: idx] == L'|') {
        symlen = [self getSymLength: @"|"];
    }
    else if ([data characterAtIndex: idx] == L'+') {
        symlen = [self getSymLength: @"+"];
    }
    else if ([data characterAtIndex: idx] == L'-') {
        symlen = [self getSymLength: @"-"];
    }
    else if ([data characterAtIndex: idx] == L'!') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: idx] == L':') {
        symlen = [self getSymLength: @":"];
    }
    else if ([data characterAtIndex: idx] == L'&') {
        symlen = [self getSymLength: @"&"];
    }
    else if ([data characterAtIndex: idx] == L'<') {
        symlen = [self getSymLength: @"="];
    }
    else if ([data characterAtIndex: idx] == L'>') {
        symlen = [self getSymLength: @"="];
    }
    else if ([operators characterIsMember: [data characterAtIndex: idx]]) {
        symlen = 1;
        opWasLast = true;
    }
    else if ([data characterAtIndex: idx] == L'"') {
        NSMutableCharacterSet *s = [[NSMutableCharacterSet alloc] init];
        [s addCharactersInString: @"\""];
        symlen = [self getSymLengthExculdingSet: s] + 1;
        opWasLast = false;
    }
    else if ([[NSCharacterSet letterCharacterSet] characterIsMember: [data characterAtIndex: idx]] || [data characterAtIndex: idx] == L'_') {
        symlen = [self getSymLengthInSet: symbols exculding: nil];
        opWasLast = false;
    }
    else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: [data characterAtIndex: idx]]) {
        opWasLast = false;
        symlen = [self getSymLengthInSet: [NSCharacterSet decimalDigitCharacterSet] exculding: [NSCharacterSet letterCharacterSet]];
    }    else {
        symlen = 1;
    }
    tok = [data substringWithRange: NSMakeRange(idx, symlen)];
    prev = idx;
    idx += symlen;
    colnum += idx;
    return tok;
}

-(void)throwException: (NSUInteger) i
{
    NSException *exception = [NSException
                              exceptionWithName: @"InvalidSyntaxException"
                              reason: [NSString stringWithFormat: @"invalid symbol %c at line: %d col %d", [data characterAtIndex: i], linenum, colnum]
                              userInfo: nil];
    @throw exception;
}

-(int)getSymLength: (NSString *)next
{
    if (opWasLast && !inLineComment && !inMultilineComment) {
        [self throwException: idx+1];
    }
    NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
    [set addCharactersInString: next];
    opWasLast = true;
    return idx < [data length] - 1 && [set characterIsMember: [data characterAtIndex: idx+1]] ? 2 : 1;
}

-(int)getSymLengthInSet: (NSCharacterSet *)set exculding: (NSCharacterSet *)exclude
{
    int len = 1;
    while (idx+len < [data length] && [set characterIsMember: [data characterAtIndex: idx+len]]) {
        len++;
    }
    if (exclude != nil && idx+len < [data length] && [exclude characterIsMember: [data characterAtIndex: idx+len]]) {
        [self throwException: idx+len];
    }
    return len;
}

-(int)getSymLengthExculdingSet: (NSCharacterSet *)set
{
    int len = 1;
    while (idx+len < [data length] && ![set characterIsMember: [data characterAtIndex: idx+len]]) {
        len++;
    }
    return len;
}

-(void)rewind
{
    if (prev != -1) {
        idx = prev;
    }
}

-(void)skipUntil: (NSString *)end
{
    NSString *s;
    while (![ s = [self nextToken] isEqualTo: end] && s != nil)
        ;
}

- (void)filter:(NSString *)from to:(NSString *)end {
    NSUInteger oldIdx = idx, start, finish;
    [self reset];
    NSString *t1, *t2;
    while ((t1 = [self nextToken]) != nil) {
        if ([t1 isEqualTo: from]) {
            start = idx - t1.length;
            while ((t2 = [self nextToken]) != nil && ![t2 isEqualTo: end])
                ;
            finish = idx;
            data = [data stringByReplacingCharactersInRange: NSMakeRange(start, finish - start) withString: @""];
            if (finish < oldIdx) {
                oldIdx -= finish - start;
            }
            idx = start;
        }
    }
    idx = oldIdx;
}

- (void)reset { 
    idx = 0;
}

@end
