//
//  QMSResourse.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSResource.h"

@implementation QMSResource

+(instancetype) newManagedObject{
    NSManagedObjectContext* context = [QMSCoreDataReusableMethod managedObjectContext];
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:context];
    Class selfClass = NSClassFromString (selfClassName);
    return [[selfClass alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
}

+(instancetype) newUnManagedObject{
    NSManagedObjectContext* context = [QMSCoreDataReusableMethod managedObjectContext];
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:context];
    Class selfClass = NSClassFromString (selfClassName);
    return [[selfClass alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}

+(instancetype) newUnManagedObjectWithContext:(NSManagedObjectContext*) context{
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:context];
    Class selfClass = NSClassFromString (selfClassName);
    return [[selfClass alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
}

+(instancetype) getPersistentObjectForKey:(NSString*) key
                        havingValue:(id) value{
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSArray *fetchedObjects = [QMSResource getPersistentObjectsForKey:key
                                                          havingValue:value
                                                        forModelClass:selfClassName];
    return [fetchedObjects lastObject];
}

+(NSArray*) getPersistentObjectsForKey:(NSString*) key
                          havingValue:(id) value{
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSArray *fetchedObjects = [QMSResource getPersistentObjectsForKey:key
                                havingValue:value
                              forModelClass:selfClassName];
    return fetchedObjects;
}

+(NSArray*) getPersistentObjectsForKey:(NSString*) key
                           havingValue:(id) value
                         forModelClass:(NSString *)selfClassName{
    NSManagedObjectContext *managedObjectContext = [QMSCoreDataReusableMethod managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *predicateString = [key stringByAppendingString:@" == %@"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat: predicateString, value];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error] ;
    return fetchedObjects;
}

+(NSFetchRequest*) fetchRequestForKey:(NSString*) key
                          havingValue:(id) value{
    NSManagedObjectContext *managedObjectContext = [QMSCoreDataReusableMethod managedObjectContext];
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *predicateString = [key stringByAppendingString:@" == %@"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat: predicateString, value];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
}

+(instancetype) getPersistentObject:(QMSResource*) resource{
    return nil;
}

+(NSArray*) fetchAllObjects{
    NSManagedObjectContext *managedObjectContext = [QMSCoreDataReusableMethod managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSString *selfClassName = NSStringFromClass ([self class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:selfClassName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error] ;
    return fetchedObjects;
}

@end
