//
//  Matrix.m
//  DZ1
//
//  Created by Filip Beć on 10/27/12.
//  Copyright (c) 2012 Filip Beć. All rights reserved.
//

#import "Matrix.h"

#define kDEBUG      YES
#define kEpsilon    1e-6

@interface Matrix () {
    double **_elements;
}

@end


@implementation Matrix

- (BOOL)isEqualTo:(id)object {
    Matrix *other = object;
    if (self.numberOfRows != other.numberOfRows || self.numberOfColumns != other.numberOfColumns) {
        return NO;
    }

    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            if (fabs([self elementFromRow:i andColumn:j] - [other elementFromRow:i andColumn:j]) > kEpsilon) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Init methods
- (id)initWithMatrixFromFileNamed:(NSString*)fileName {
    self = [super init];
    if (self) {
#warning todo
    }
    
    return self;
}

- (id)initWithNumberOfRows:(NSUInteger)numberOfRows andNumberOfColumns:(NSUInteger)numberOfColumns {
    self = [super init];
    if (self) {
        _elements = (double**)malloc(numberOfRows * sizeof(double*));
        
        for (int i = 0; i < numberOfRows; i++) {
            _elements[i] = malloc(numberOfColumns * sizeof(double));
            for (int j = 0; j < numberOfColumns; j++) {
                _elements[i][j] = 0;
            }
        }
        self.numberOfRows = numberOfRows;
        self.numberOfColumns = numberOfColumns;
    }
    return self;
}

- (id)initWithMatrix:(Matrix*)matrix {
    self = [super init];
    if (self) {
        _elements = (double**)malloc(matrix.numberOfRows * sizeof(double*));
        
        for (int i = 0; i < matrix.numberOfRows; i++) {
            _elements[i] = malloc(matrix.numberOfColumns * sizeof(double));
        }
        
        for (int i = 0; i < matrix.numberOfRows; i++) {
            for (int j = 0; j < matrix.numberOfColumns; j++) {
                _elements[i][j] = [matrix elementFromRow:i andColumn:j];
            }
        }
        self.numberOfRows = matrix.numberOfRows;
        self.numberOfColumns = matrix.numberOfColumns;
    }
    return self;
}

#pragma mark - Getter and setter for element of matrix

- (double)elementFromRow:(NSUInteger)row andColumn:(NSUInteger)column {
    return _elements[row][column];
}

- (void)setElement:(double)element atRow:(NSUInteger)row andColumn:(NSUInteger)column {
    if (row < self.numberOfRows && column < self.numberOfColumns) {
        _elements[row][column] = element;
    } else {
        fprintf(stderr, "Invalid index (%ld, %ld)\n", row, column);
    }
}


#pragma mark - Operations that returns new matrix
- (Matrix*)matrixByAddingMatrix:(Matrix*)matrix {
    if (self.numberOfRows != matrix.numberOfRows || self.numberOfColumns != matrix.numberOfColumns) {
        fprintf(stderr, "Matrix dimensions not compatible\n");
        return nil;
    }
    
    Matrix *newMatrix = [[Matrix alloc] initWithMatrix:self];
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [newMatrix setElement:([newMatrix elementFromRow:i andColumn:j] + [matrix elementFromRow:i andColumn:j]) atRow:i andColumn:j];
        }
    }
    return newMatrix;
}

- (Matrix*)matrixBySubstractingMatrix:(Matrix*)matrix {
    if (self.numberOfRows != matrix.numberOfRows || self.numberOfColumns != matrix.numberOfColumns) {
        fprintf(stderr, "Matrix dimensions not compatible\n");
        return nil;
    }
    
    Matrix *newMatrix = [[Matrix alloc] initWithMatrix:self];
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [newMatrix setElement:([newMatrix elementFromRow:i andColumn:j] - [matrix elementFromRow:i andColumn:j]) atRow:i andColumn:j];
        }
    }
    return newMatrix;
}

- (Matrix*)matrixByMultiplyingWithMatrix:(Matrix*)matrix {
    if (self.numberOfColumns != matrix.numberOfRows) {
        fprintf(stderr, "Matrix dimensions not compatible\n");
        return nil;
    }
    
    Matrix *newMatrix = [[Matrix alloc] initWithNumberOfRows:self.numberOfRows andNumberOfColumns:matrix.numberOfColumns];
    
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < matrix.numberOfColumns; j++) {
            double s = 0;
            for (int k = 0; k < matrix.numberOfRows; k++) {
                s += [self elementFromRow:i andColumn:k] * [matrix elementFromRow:k andColumn:j];
            }
            [newMatrix setElement:s atRow:i andColumn:j];
        }
    }
    return newMatrix;
}

- (Matrix*)matrixByMultiplyingWithScalar:(double)scalar {
    Matrix *newMatrix = [[Matrix alloc] initWithMatrix:self];
    for (int i = 0; i < newMatrix.numberOfRows; i++) {
        for (int j = 0; j < newMatrix.numberOfColumns; j++) {
            [newMatrix setElement:([newMatrix elementFromRow:i andColumn:j] * scalar) atRow:i andColumn:j];
        }
    }
    return newMatrix;
}

- (Matrix*)transposedMatrix {
    Matrix *newMatrix = [[Matrix alloc] initWithNumberOfRows:self.numberOfColumns andNumberOfColumns:self.numberOfRows];
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [newMatrix setElement:[self elementFromRow:i andColumn:j] atRow:j andColumn:i];
        }
    }
    return newMatrix;
}

#pragma mark - Operations with current matrix
- (void)addMatrix:(Matrix*)matrix {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [self setElement:([self elementFromRow:i andColumn:j] + [matrix elementFromRow:i andColumn:j]) atRow:i andColumn:j];
        }
    }
}

- (void)substactMatrix:(Matrix*)matrix {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [self setElement:([self elementFromRow:i andColumn:j] - [matrix elementFromRow:i andColumn:j]) atRow:i andColumn:j];
        }
    }
}

- (void)multiplyByScalar:(double)scalar {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            [self setElement:([self elementFromRow:i andColumn:j] * scalar) atRow:i andColumn:j];
        }
    }
}

- (void)transpose {
    if (self.numberOfColumns == self.numberOfRows) {
        for (int i = 0; i < self.numberOfRows; i++) {
            for (int j = i; j < self.numberOfColumns; j++) {
                double temp = [self elementFromRow:i andColumn:j];
                [self setElement:[self elementFromRow:j andColumn:i] atRow:i andColumn:j];
                [self setElement:temp atRow:j andColumn:i];
            }
        }
    } else {
        double **oldElements = _elements;
        _elements = (double**)malloc(self.numberOfColumns * sizeof(double*));
        
        for (int i = 0; i < self.numberOfColumns; i++) {
            _elements[i] = malloc(self.numberOfRows * sizeof(double));
            for (int j = 0; j < self.numberOfRows; j++) {
                _elements[i][j] = 0;
            }
        }


        for (int i = 0; i < self.numberOfRows; i++) {
            for (int j = 0; j < self.numberOfColumns; j++) {
                _elements[j][i] = oldElements[i][j];
            }
        }
        
        [self freeElements:oldElements forNumberOfRows:self.numberOfRows];
        
        NSUInteger temp = self.numberOfRows;
        self.numberOfRows = self.numberOfColumns;
        self.numberOfColumns = temp;
    }
}


#pragma mark - Decomposition
- (BOOL)LUDecomposition {
    if (self.numberOfRows != self.numberOfColumns) {
        fprintf(stderr, "LU decomposition error.\n");
        return NO;
    }
    
    for (int i = 0; i < self.numberOfRows-1; i++) {
        for (int j = i+1; j < self.numberOfRows; j++) {
            if (fabs(_elements[i][i]) < kEpsilon) {
                fprintf(stderr, "LU decomposition error.\n");
                return NO;
            }
            _elements[j][i] /= _elements[i][i];
            for (int k = i+1; k < self.numberOfRows; k++) {
                _elements[j][k] -= _elements[j][i] * _elements[i][k];
            }
        }
    }
    return YES;
}

- (Matrix*)LUPDecomposition {
    if (self.numberOfRows != self.numberOfColumns) {
        fprintf(stderr, "LUP decomposition error.\n");
        return nil;
    }
    
    Matrix *P = [[Matrix alloc] initWithNumberOfRows:self.numberOfRows andNumberOfColumns:self.numberOfColumns];
    for (int i = 0; i < self.numberOfRows; i++) {
        [P setElement:1 atRow:i andColumn:i];
    }
    
    for (int i = 0; i < self.numberOfRows-1; i++) {
        NSUInteger pivot = i;
        for (int j = i+1; j < self.numberOfRows; j++) {
            double el1 = [self elementFromRow:j andColumn:i];
            double el2 = [self elementFromRow:pivot andColumn:i];
            if (fabs(el1) > fabs(el2)) {
                pivot = j;
            }
        }
        
        [self replaceRowAtIndex:i withRowAtIndex:pivot];
        [P replaceRowAtIndex:i withRowAtIndex:pivot];
        
        if (kDEBUG) {
            NSLog(@"MIJENJAM %d i %ld", i, pivot);
            printf("MATRICA:\n");
            [self printMatrixToStream:stdout];
        }
        
        for (int j = i+1; j < self.numberOfRows; j++) {
            if (fabs(_elements[i][i]) < kEpsilon) {
                fprintf(stderr, "LUP decomposition error.\n");
                return nil;
            }
            _elements[j][i] /= _elements[i][i];
            for (int k = i+1; k < self.numberOfRows; k++) {
                _elements[j][k] -= _elements[j][i] * _elements[i][k];
            }
        }

    }
    
    [P transpose];
    return P;
}

- (Matrix*)matrixL {
    Matrix *L = [[Matrix alloc] initWithNumberOfRows:self.numberOfRows andNumberOfColumns:self.numberOfColumns];
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            if (j == i) {
                [L setElement:1.0 atRow:i andColumn:j];
            } else if (j > i) {
                [L setElement:0.0 atRow:i andColumn:j];
            } else {
                [L setElement:[self elementFromRow:i andColumn:j] atRow:i andColumn:j];
            }
        }
    }
    return L;
}

- (Matrix*)matrixU {
    Matrix *U = [[Matrix alloc] initWithNumberOfRows:self.numberOfRows andNumberOfColumns:self.numberOfColumns];
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            if (j < i) {
                [U setElement:0.0 atRow:i andColumn:j];
            } else {
                [U setElement:[self elementFromRow:i andColumn:j] atRow:i andColumn:j];
            }
        }
    }
    return U;
}

#pragma mark - Substitutions
- (void)forwardSupstitutionWithMatrix:(Matrix*)L {
    for (int i = 0; i < self.numberOfRows-1; i++) {
        for (int j = i+1; j < self.numberOfRows; j++) {
            NSLog(@"i = %d, j = %d, L = %lf, el = %lf", i, j, [L elementFromRow:j andColumn:i], _elements[i][0]);
            _elements[j][0] -= [L elementFromRow:j andColumn:i] * _elements[i][0];
        }
    }
}

- (void)backSupstitutionWithMatrix:(Matrix*)U {
    for (NSUInteger i = self.numberOfRows-1; i > 0; i--) {
        if ([U elementFromRow:i andColumn:i] < kEpsilon) {
#warning TODO
        }
        _elements[i][0] /= [U elementFromRow:i andColumn:i];
        for (NSUInteger j = 0; j < i-1; j++) {
            _elements[j][0] -= [U elementFromRow:j andColumn:i] * _elements[i][0];
        }
    }
}


#pragma mark - Print matrix
- (void)printMatrixComponentLToStream:(FILE*)fileStream {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            if (j == i) {
                fprintf(fileStream, "%f ", 1.0);
            } else if (j > i) {
                fprintf(fileStream, "%f ", 0.0);
            } else {
                fprintf(fileStream, "%f ", [self elementFromRow:i andColumn:j]);
            }
        }
        fprintf(fileStream, "\n");
    }
}

- (void)printMatrixComponentUToStream:(FILE*)fileStream {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            if (j < i) {
                fprintf(fileStream, "%f ", 0.0);
            } else {
                fprintf(fileStream, "%f ", [self elementFromRow:i andColumn:j]);
            }
        }
        fprintf(fileStream, "\n");
    }
}

- (void)printMatrixToStream:(FILE*)fileStream {
    for (int i = 0; i < self.numberOfRows; i++) {
        for (int j = 0; j < self.numberOfColumns; j++) {
            fprintf(fileStream, "%f ", [self elementFromRow:i andColumn:j]);
        }
        fprintf(fileStream, "\n");
    }
}

#pragma mark - Free matrix
- (void)dealloc {
    [self freeElements:_elements forNumberOfRows:self.numberOfRows];
    self.numberOfColumns = 0;
    self.numberOfRows = 0;
}

#pragma mark - Helper functions
- (void)freeElements:(double**)elements forNumberOfRows:(NSUInteger)numberOfRows {
    for (int i = 0; i < numberOfRows; i++) {
        free(elements[i]);
    }
    free(elements);
}

- (BOOL)replaceRowAtIndex:(NSUInteger)firstRow withRowAtIndex:(NSUInteger)secondRow {
    if (firstRow < self.numberOfRows || secondRow < self.numberOfRows) {
        double *tempRow = _elements[firstRow];
        _elements[firstRow] = _elements[secondRow];
        _elements[secondRow] = tempRow;
        return YES;
    } else {
        fprintf(stderr, "Error replacing rows.");
    }
    return NO;
}

@end
