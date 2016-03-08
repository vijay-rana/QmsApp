//
//  QMSCoreDataReusableMethod.m
//  ServShare
//
//  Created by Mac Book Pro on 27/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import "QMSCoreDataReusableMethod.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

#define APP_DEFAULT_FOLDER @"DownloadedPDF"

@implementation QMSCoreDataReusableMethod

+(NSManagedObjectContext*) managedObjectContext{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* managedObjectContext = appDelegate.managedObjectContext;
    return managedObjectContext;
}

+(NSPersistentStoreCoordinator*) persistentStoreCoordinator{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSPersistentStoreCoordinator* persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    return persistentStoreCoordinator;
}

+(NSInteger) countForFetchRequest:(NSFetchRequest*) fetchRequest{
    NSError *error = nil;
    NSManagedObjectContext* managedObjectContext = [QMSCoreDataReusableMethod managedObjectContext];
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest
                                                            error:&error];
    if (count == NSNotFound) {
        NSLog(@"Error: %@", error);
        return 0;
    }
    return count;
}

+(NSManagedObject *)objectWithURI:(NSURL *)uri{
    NSManagedObjectID *objectID =
    [[QMSCoreDataReusableMethod persistentStoreCoordinator]
     managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    
    NSManagedObject *objectForID = [[QMSCoreDataReusableMethod managedObjectContext] objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }
   
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:[objectID entity]];
    
    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
    [NSComparisonPredicate
     predicateWithLeftExpression:
     [NSExpression expressionForEvaluatedObject]
     rightExpression:
     [NSExpression expressionForConstantValue:objectForID]
     modifier:NSDirectPredicateModifier
     type:NSEqualToPredicateOperatorType
     options:0];
    [request setPredicate:predicate];
    
    NSArray *results = [[QMSCoreDataReusableMethod managedObjectContext] executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return results[0];
    }
    
    return nil;
}

+(void) saveContext{
    NSManagedObjectContext *context = [QMSCoreDataReusableMethod managedObjectContext];
    [QMSCoreDataReusableMethod saveContext:context];
}

+(void) saveContext:(NSManagedObjectContext*) context{
    NSError *error;
    [context save:&error];
    if (error != nil){
        NSLog(@"Whoops, couldn't save: %@",[error localizedDescription]);
        NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        }
        else {
            NSLog(@"  %@", [error userInfo]);
        }
    }
}

+(void) insertObjectIntoContext:(QMSResource*) object{
    NSManagedObjectContext *context = [QMSCoreDataReusableMethod managedObjectContext];
    [context insertObject:object];
}


+(NSData*) readFileOfName:(NSString*) fileName{
    return [QMSCoreDataReusableMethod readFileOfName:fileName
                                          fromFolder:APP_DEFAULT_FOLDER];
}

+(void) saveFile:(NSData *) data ofName:(NSString*) fileName{
    [QMSCoreDataReusableMethod saveFile:data
                                 ofName:fileName
                             intoFolder:APP_DEFAULT_FOLDER];
}

+(NSData*) readFileOfName:(NSString*) fileName
               fromFolder:(NSString*) folderName{
    NSString *filePath = [QMSCoreDataReusableMethod filePathForFileName:fileName
                                                           withFolderName:folderName];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    return data;
}

+(void) saveFile:(NSData *) data
          ofName:(NSString*) fileName
      intoFolder:(NSString*) folderName{
    NSString *filePath = [QMSCoreDataReusableMethod filePathForFileName:fileName
                                                             withFolderName:folderName];
    [data writeToFile:filePath atomically:YES];
}

+(NSString*) filePathForFileName:(NSString*) fileName
               withFolderName:(NSString *) folderName{
    NSString *curentUserName = [[QMSUser currentUser] valueForKey:@"userName"];
    folderName = [curentUserName stringByAppendingPathComponent:folderName];
    NSString *folderPath = [QMSCoreDataReusableMethod documentsDirectoryPathOfFolder:folderName];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+(NSString*) documentsDirectoryPathOfFolder:(NSString*) folder{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
    }
    return dataPath;
}

#pragma Mark-
#pragma Mark Set/Get values from NSUserDefault
+(void)saveToUserDefaults:(NSString*)key value :(id)value{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:value forKey:key];
        [standardUserDefaults synchronize];
    }
}


+(NSString*)retrieveFromUserDefaults:(NSString*)key{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    
    if (standardUserDefaults)
        val = [standardUserDefaults objectForKey:key];
    
    return val;
}

+(UIImage *)convertByteToUIImage: (NSString *)byteImage{
    
    NSData *datos = [QMSCoreDataReusableMethod convertByteToNSData:byteImage];
    UIImage *image = [UIImage imageWithData:datos];
    
    return image;
}

+(NSData *)convertByteToNSData: (NSString *)byteImage{
    
    NSArray *strings = [byteImage componentsSeparatedByString:@","];
    
    unsigned c = (unsigned) strings.count;
    uint8_t *bytes = malloc(sizeof(*bytes) * c);
    
    unsigned i;
    for (i = 0; i < c; i++)
    {
        NSString *str = strings[i];
        int byte = [str intValue];
        bytes[i] = (uint8_t)byte;
    }
    
    NSData *datos = [NSData dataWithBytes:bytes length:c];
    
    return datos;
}

+(NSData *)convertByteArrayToNSData: (NSArray *)strings{
    
//    NSArray *strings = [byteImage componentsSeparatedByString:@","];
    
    unsigned c = (unsigned) strings.count;
    uint8_t *bytes = malloc(sizeof(*bytes) * c);
    
    unsigned i;
    for (i = 0; i < c; i++)
    {
        NSString *str = strings[i];
        int byte = [str intValue];
        bytes[i] = (uint8_t)byte;
    }
    
    NSData *datos = [NSData dataWithBytes:bytes length:c];
    
    return datos;
}

@end
