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
    NSString *_convertBlockNSBase;
    NSString *_typeInitNS;
}

@property NSString *name;
@property NSString *containingNamespace;
@property NSUInteger nTypeParameters;
@property NSString *customName;
@property NSString *convertBlockNSBase;
@property (getter=typeInitNS, setter=setTypeInitNS:) NSString *typeInitNS;

-(id)init;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withCustomName: (NSString *) otherName;
-(id) initWithName: (NSString *) name inNamespace: (NSString *)ns withParams: (NSUInteger) nParams;
- (NSString *) nameforNS;
- (NSString *) convertBlockNS: (NSString *) src to: (NSString *) dst;

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
