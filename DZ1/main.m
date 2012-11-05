//
//  main.m
//  DZ1
//
//  Created by Filip Beć on 10/27/12.
//  Copyright (c) 2012 Filip Beć. All rights reserved.
//
#import "Matrix.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"DZ1";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        
#warning ovdje ide glavni program
        
        Matrix *A = [[Matrix alloc] initWithNumberOfRows:3 andNumberOfColumns:3];
        Matrix *b = [[Matrix alloc] initWithNumberOfRows:3 andNumberOfColumns:1];
        
        [b setElement:2 atRow:0 andColumn:0];
        [b setElement:3 atRow:1 andColumn:0];
        [b setElement:4 atRow:2 andColumn:0];
        
        
        [A setElement:6 atRow:0 andColumn:0];
        [A setElement:2 atRow:0 andColumn:1];
        [A setElement:10 atRow:0 andColumn:2];
        
        [A setElement:2 atRow:1 andColumn:0];
        [A setElement:3 atRow:1 andColumn:1];
        [A setElement:0 atRow:1 andColumn:2];
        
        [A setElement:0 atRow:2 andColumn:0];
        [A setElement:4 atRow:2 andColumn:1];
        [A setElement:2 atRow:2 andColumn:2];
        
        
        printf("Matrica A:\n");
        [A printMatrixToStream:stdout];
        
        Matrix *LU = [[Matrix alloc] initWithMatrix:A];
        
        if ([LU LUDecomposition]) {
            Matrix *L = [LU matrixL];
            Matrix *U = [LU matrixU];

//            printf("Matrica P:\n");
//            [P printMatrixToStream:stdout];
            
            printf("Matrix b:\n");
            [b printMatrixToStream:stdout];
            
            printf("Matrica L:\n");
            [L printMatrixComponentLToStream:stdout];
            
            printf("Matrica U:\n");
            [U printMatrixComponentUToStream:stdout];

            Matrix *y = [[Matrix alloc] initWithMatrix:b];
            [y forwardSupstitutionWithMatrix:LU];
            printf("Matrica y:\n");
            [y printMatrixToStream:stdout];
            
            Matrix *x = [[Matrix alloc] initWithMatrix:y];
            [x backSupstitutionWithMatrix:LU];
            printf("Matrica x:\n");
            [x printMatrixToStream:stdout];
        }

        
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
    return 0;
}

