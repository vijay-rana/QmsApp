//
//  SSCoreDataReusableMethod.h
//  ServShare
//
//  Created by Mac Book Pro on 27/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSCoreDataReusableMethod : NSObject

+(void)saveToUserDefaults:(NSString*)key value :(id)value;
+(NSString*)retrieveFromUserDefaults:(NSString*)key;

+(NSManagedObjectContext*) managedObjectContext;
+(NSPersistentStoreCoordinator*) persistentStoreCoordinator;
+(NSInteger) countForFetchRequest:(NSFetchRequest*) fetchRequest;
+(NSManagedObject *)objectWithURI:(NSURL *)uri;
+(void) saveContext;
+(void) saveContext:(NSManagedObjectContext*) context;
+(void) insertObjectIntoContext:(QMSResource*) object;

+(NSString*) filePathForFileName:(NSString*) fileName
                    withFolderName:(NSString *) folderName;
+(NSString*) documentsDirectoryPathOfFolder:(NSString*) folder;
+(void) saveFile:(NSData *) data ofName:(NSString*) fileName;
+(NSData*) readFileOfName:(NSString*) fileName;
+(void) saveFile:(NSData *) data
          ofName:(NSString*) fileName
      intoFolder:(NSString*) folderName;
+(NSData*) readFileOfName:(NSString*) fileName
               fromFolder:(NSString*) folderName;

+(UIImage *)convertByteToUIImage: (NSString *)byteImage;
+(NSData *)convertByteToNSData: (NSString *)byteImage;
+(NSData *)convertByteArrayToNSData: (NSArray *)strings;

@end
