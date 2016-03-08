//
//  QMSResourse.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface QMSResource : NSManagedObject

+(instancetype) newManagedObject;
+(instancetype) newUnManagedObject;
+(instancetype) newUnManagedObjectWithContext:(NSManagedObjectContext*) context;


+(instancetype) getPersistentObjectForKey:(NSString*) key
                        havingValue:(id) value;
+(NSArray*) getPersistentObjectsForKey:(NSString*) key
                           havingValue:(id) value;
+(NSFetchRequest*) fetchRequestForKey:(NSString*) key
                          havingValue:(id) value;
+(instancetype) getPersistentObject:(QMSResource*) resource;
+(NSArray*) fetchAllObjects;
@end
