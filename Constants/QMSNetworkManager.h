//
//  QMSNetworkManager.h
//  QMS
//
//  Created by Mac Book Pro on 07/06/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSNetworkManager : NSObject
+(instancetype) sharedManager;

- (void)getUserLoginFromService:(NSString *)regUserName :(NSString *)password;
@end


@interface QMSLicenseNetworkManager : NSObject
+(instancetype) sharedManager;

- (void)checkUserLicenseExpiryDateFromService;
@end