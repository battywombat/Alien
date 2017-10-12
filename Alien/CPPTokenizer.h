//
//  CPPTokenizer.h
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

@interface CPPTokenizer : NSObject
{
    @private
    NSString *data;
    
    @private
    int i;
    
    @private
    int prev;
    
    int linenum;
    int colnum;

    BOOL inLineComment;
    BOOL inMultilineComment;
    BOOL op_was_last;
}

-(id)initFromString: (NSString *) s;

-(id)initFromFile: (NSString *) fp;

-(NSString *)nextToken;

-(void)throwException: (int) idx;

-(int)getSymLength: (NSString *)next;

-(int)getSymLengthInSet: (NSCharacterSet *)set exculding: (NSCharacterSet *)exclude;

-(int)getSymLengthExculdingSet: (NSCharacterSet *)set;

-(void)rewind;

-(void)skipUntil: (NSString *)end;

@end
