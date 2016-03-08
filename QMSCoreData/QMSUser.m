//
//  QMSUser.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSUser.h"


@implementation QMSUser

@dynamic userName;
@dynamic token;
@dynamic isCurrentUser;
@dynamic password;

+(void) saveUser:(QMSUser*) user{
      QMSUser *persiUser = [QMSUser getPersistentObjectForKey:@"userName" havingValue:[user valueForKey:@"userName"]];
    [QMSUser markOtherUserInactive];
    if (persiUser == nil) {
        [user setIsCurrentUser:@(1)];
        [QMSCoreDataReusableMethod insertObjectIntoContext:user];
    } else{
        [persiUser setIsCurrentUser:@(1)];
    }
    [QMSCoreDataReusableMethod saveContext];
}

+(QMSUser*) currentUser{
    return [QMSUser getPersistentObjectForKey:@"isCurrentUser" havingValue:@(1)];
}

+(void) markOtherUserInactive{
    NSArray *activeUser = [QMSUser getPersistentObjectsForKey:@"isCurrentUser" havingValue:@(1)];
    [activeUser enumerateObjectsUsingBlock:^(QMSUser* obj, NSUInteger idx, BOOL *stop) {
        [obj setIsCurrentUser:@(0)];
    }];
    [QMSCoreDataReusableMethod saveContext];
}

@end

@implementation QMSUser (QMSTableViewDatasourceDisplayObject)

-(NSString*) detailLabelText{
    return [self valueForKey:@"userName"];
}

@end