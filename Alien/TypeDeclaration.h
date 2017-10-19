//
//  TypeDeclaration.h
//  Alien
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeDeclaration : NSObject
{
    @private
    NSString *_convertBlockCppBase;
    NSString *_typeInitNS;
}

@property NSString *name;
@property NSString *containingNamespace;
@property NSUInteger nTypeParameters;
@property NSString *customName;
@property (getter=typeInitCpp, setter=setTypeInitCpp:) NSString *typeInitCpp;
@property NSString *insertionNS;
@property NSString *insertionCpp;
@property NSString *convertCpp;
@property NSString *convertNS;

-(id)init;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withCustomName: (NSString *) otherName;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withParams: (NSUInteger) nParams;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;
- (NSString *) nameForNS;
- (NSString *) nameForCpp;

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
