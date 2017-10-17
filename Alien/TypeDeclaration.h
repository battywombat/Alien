//
//  TypeDeclaration.h
//  Alien
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeDeclaration : NSObject

@property NSString *name;
@property NSString *containingNamespace;
@property NSUInteger nTypeParameters;
@property NSString *customName;

-(id)init;

-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withCustomName: (NSString *) otherName;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withParams: (NSUInteger) nParams;
- (NSString *) nameforNS;

+ (TypeDeclaration *)doubleType;
+ (TypeDeclaration *)floatType;
+ (TypeDeclaration *)charType;
+ (TypeDeclaration *)voidType;
+ (TypeDeclaration *)intType;
+ (TypeDeclaration *)stringType;
+ (TypeDeclaration *)vectorType;
+ (TypeDeclaration *)mapType;
+ (TypeDeclaration *)boolType;


@end
