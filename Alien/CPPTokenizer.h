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

    BOOL in_line_comment;
    BOOL in_multiline_comment;
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

@end
