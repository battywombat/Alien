//
//  TypeDefinition.h
//  Alien
//
//  Created by Paul Warner on 10/14/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TypeDeclaration.h"

@interface Type : NSObject

@property TypeDeclaration *typeDecl;
@property NSMutableArray <Type *> *typeParameters;
@property NSUInteger indirectionCount;
@property BOOL isReference;
@property BOOL constPtr;
@property (readonly) NSMutableArray <NSString *> *qualifiers;

-(id)init;

-(id)initWithType: (TypeDeclaration *) type;

-(NSString *)typeForNS;

-(NSString *)typeWithParens;

-(NSString *)convertToNS: (NSString *) srcDecl dest: (NSString *) destDecl;

-(BOOL)addQualifier: (NSString *) qualifier;

@end
