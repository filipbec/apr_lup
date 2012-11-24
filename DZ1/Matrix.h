//
//  Matrix.h
//  DZ1
//
//  Created by Filip Beć on 10/27/12.
//  Copyright (c) 2012 Filip Beć. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Matrix : NSObject

@property (atomic, assign) NSUInteger numberOfRows;
@property (atomic, assign) NSUInteger numberOfColumns;

#pragma mark - Init methods
- (id)initWithMatrixFromFileNamed:(char*)fileName;
- (id)initWithNumberOfRows:(NSUInteger)numberOfRows andNumberOfColumns:(NSUInteger)numberOfColumns;
- (id)initWithMatrix:(Matrix*)matrix;

#pragma mark - Getter and setter for element of matrix
- (double)elementFromRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (void)setElement:(double)element atRow:(NSUInteger)row andColumn:(NSUInteger)column;

#pragma mark - Operations that returns new matrix
- (Matrix*)matrixByAddingMatrix:(Matrix*)matrix;
- (Matrix*)matrixBySubstractingMatrix:(Matrix*)matrix;
- (Matrix*)matrixByMultiplyingWithMatrix:(Matrix*)matrix;
- (Matrix*)matrixByMultiplyingWithScalar:(double)scalar;
- (Matrix*)transposedMatrix;

#pragma mark - Operations with current matrix
- (void)addMatrix:(Matrix*)matrix;
- (void)substactMatrix:(Matrix*)matrix;
- (void)multiplyByScalar:(double)scalar;
- (void)transpose;

#pragma mark - Decomposition
- (BOOL)LUDecomposition;        //returns NO if decomposition can't be done
- (Matrix*)LUPDecomposition;    //returns nil if decomposition can't be done, else returns array
- (Matrix*)matrixL;
- (Matrix*)matrixU;

#pragma mark - Substitutions
- (void)forwardSupstitutionWithMatrix:(Matrix*)L;
- (void)backSupstitutionWithMatrix:(Matrix*)U;

#pragma mark - Print matrix
- (void)printMatrixComponentLToStream:(FILE*)fileStream;
- (void)printMatrixComponentUToStream:(FILE*)fileStream;
- (void)printMatrixToStream:(FILE*)fileStream;

@end
