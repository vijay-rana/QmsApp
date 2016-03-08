//
//  QMSUser.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSResource.h"

@interface QMSUser : QMSResource

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSNumber * isCurrentUser;
@property (nonatomic, retain) NSString * password;

+(void) saveUser:(QMSUser*) user;
+(QMSUser*) currentUser;
@end

@interface QMSUser (QMSTableViewDatasourceDisplayObject) <QMSTableViewDatasourceDisplayObject>

@end