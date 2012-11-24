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
        
        //GLAVNI PROGRAM
        
        Matrix *A = nil;
        Matrix *b = nil;
        
        int option = 0;

        //ucitavanje matrica
        do {
            printf("1) Ucitati matricu A iz datoteke\n2) Upisati elemente matrice A\nUpisite broj: ");
            scanf("%d", &option);
        } while (option != 1 && option != 2);
        
        if (option == 1) {
            char fileNameA[256];
            printf("Upisite ime/putanju datoteke: ");
            scanf("%s", fileNameA);
            A = [[Matrix alloc] initWithMatrixFromFileNamed:fileNameA];
            if (!A) {
                exit(0);
            }
        } else {
            NSUInteger n, m;
            printf("Upisite broj redaka i stupaca matrice: ");
            scanf("%ld %ld", &n, &m);
            A = [[Matrix alloc] initWithNumberOfRows:n andNumberOfColumns:m];
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < m; j++) {
                    double tmp = 0.0;
                    printf("A[%d,%d]: ", i, j);
                    scanf("%lf", &tmp);
                    [A setElement:tmp atRow:i andColumn:j];
                }
            }
        }
        
        //ucitavanje matrice b
        do {
            printf("1) Ucitati matricu B iz datoteke\n2) Upisati elemente matrice B\nUpisite broj: ");
            scanf("%d", &option);
        } while (option != 1 && option != 2);
        
        if (option == 1) {
            char fileNameB[256];
            printf("Upisite ime/putanju datoteke: ");
            scanf("%s", fileNameB);
            b = [[Matrix alloc] initWithMatrixFromFileNamed:fileNameB];
            if (!b) {
                exit(0);
            }
        } else {
            NSUInteger n = A.numberOfRows;
            NSUInteger m = 1;
            b = [[Matrix alloc] initWithNumberOfRows:n andNumberOfColumns:m];
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < m; j++) {
                    double tmp = 0.0;
                    printf("B[%d,%d]: ", i, j);
                    scanf("%lf", &tmp);
                    [b setElement:tmp atRow:i andColumn:j];
                }
            }
        }
        
        int LUP = 0;
        do {
            printf("1) LU dekompozicija\n2) LUP dekompozicija\nUpisite broj: ");
            scanf("%d", &LUP);
        } while (LUP != 1 && LUP != 2);
        //kraj ucitavanja
        
        Matrix *LU = [[Matrix alloc] initWithMatrix:A];
        Matrix *L = nil;
        Matrix *U = nil;
        Matrix *P = nil;
        Matrix *y = nil;
        Matrix *x = nil;
        
        if (LUP == 1) {
            //LU dekompozicija
            if ([LU LUDecomposition]) {
                L = [LU matrixL];
                U = [LU matrixU];
                
                y = [[Matrix alloc] initWithMatrix:b];
                [y forwardSupstitutionWithMatrix:L];

                x = [[Matrix alloc] initWithMatrix:y];
                [x backSupstitutionWithMatrix:U];
            } else {
                exit(0);
            }
        } else {
            //LUP dekompozicija
            if((P = [LU LUPDecomposition]) != nil) {
                b = [P matrixByMultiplyingWithMatrix:b];
                
                L = [LU matrixL];
                U = [LU matrixU];
                
                y = [[Matrix alloc] initWithMatrix:b];
                [y forwardSupstitutionWithMatrix:LU];
                
                x = [[Matrix alloc] initWithMatrix:y];
                [x backSupstitutionWithMatrix:U];
            } else {
                exit(0);
            }
        }
        
        printf("\nMatrica L:\n");
        [L printMatrixComponentLToStream:stdout];

        printf("\nMatrica U:\n");
        [U printMatrixComponentUToStream:stdout];
        
        printf("\nMatrica y:\n");
        [y printMatrixToStream:stdout];
        
        if (LUP == 2) {
            printf("\nMatrica P:\n");
            [P printMatrixToStream:stdout];
        }
        
        do {
            printf("1) Ispisati rezultat na ekran\n2) Ispisati rezultat u datoteku\nUpisite broj: ");
            scanf("%d", &option);
        } while (option != 1 && option != 2);
        
        FILE *f = NULL;
        if (option == 1) {
            f = stdout;
            printf("\nMatrica x:\n");
            [x printMatrixToStream:f];
        } else {
            char fileName[256] = {0};
            printf("Upisite ime/putanju datoteke: ");
            scanf("%s", fileName);
            if ((f = fopen(fileName, "w+")) != NULL) {
                [x printMatrixToStream:f];
            } else {
                fprintf(stderr, "Error opening file");
            }
            fclose(f);
        }
        
//KRAJ GLAVNOG PROGRAMA
        
        
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
    return 0;
}

