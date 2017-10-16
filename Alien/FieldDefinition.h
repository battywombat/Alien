//
//  FieldDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Type.h"

enum AccessLevel {
    NONE = 0,
    PUBLIC,
    PRIVATE,
    PROTECTED
};

@interface FieldDefinition : NSObject

@property NSString *name;
@property Type *type;
@property enum AccessLevel accessLevel;

-(id)initWithName : (NSString *) name andType: (Type *) type;

-(id)initWithName : (NSString *) name andType: (Type *) type andAccessLevel: (enum AccessLevel) accessLevel;

@end
