//
//  QMSNetworkManager.m
//  QMS
//
//  Created by Mac Book Pro on 07/06/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSNetworkManager.h"

@interface QMSNetworkManager (){
    NSMutableData *httpResponseData;
    NSURLConnection *connection;
}

@end

@implementation QMSNetworkManager

+(instancetype) sharedManager{
    static QMSNetworkManager *mgr = nil;
    if (mgr == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mgr = [[QMSNetworkManager alloc] init];
        });
    }
    return mgr;
}

- (void)getUserLoginFromService:(NSString *)regUserName :(NSString *)password{
    
    [connection cancel];
    connection = nil;
    
    NSUserDefaults *saveUserName = [NSUserDefaults standardUserDefaults];
    [saveUserName setObject:regUserName forKey:@"regUserName"];
    
    
    // Your JSON data: {"user":{"UserName":"TestUserName3", "Password":"TestPassword3"}}
    NSString *loginArray =[NSString stringWithFormat:@"{\"user\":{\"UserName\":\"%@\",\"Password\":\"%@\"}}",regUserName,password];
    NSLog(@"loginArray=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://qmswatch.kindlebit.com/API.asmx/AuthenticateUser"]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    httpResponseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [httpResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [httpResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
    
    
    //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
    
    NSString * codeR = [dict[@"d"][@"ResponseCode"] stringValue];
    NSString * codemsg = dict[@"d"][@"Message"];
    NSString* userToken=dict[@"d"][@"Token"];
    
    if ([codeR isEqualToString:@"200"]){
        //saving Token
        NSUserDefaults *saveUserToken = [NSUserDefaults standardUserDefaults];
        [saveUserToken setObject:userToken forKey:@"Token"];
        [saveUserToken synchronize];
        
        QMSLicenseNetworkManager *licence = [[QMSLicenseNetworkManager alloc] init];
        [licence checkUserLicenseExpiryDateFromService];
    }
    else{
        [QMSCoreDataReusableMethod saveToUserDefaults:@"isLoggedIn" value:@(0)];
    }
}

@end

@interface QMSLicenseNetworkManager (){
    NSMutableData *httpResponseData;
    NSURLConnection *connection;
}

@end

@implementation QMSLicenseNetworkManager

+(instancetype) sharedManager{
    static QMSLicenseNetworkManager *mgr = nil;
    if (mgr == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mgr = [[QMSLicenseNetworkManager alloc] init];
        });
    }
    return mgr;
}

- (void)checkUserLicenseExpiryDateFromService{
    [connection cancel];
    connection = nil;
    
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    NSString * reguserToken = [retriveUserToken stringForKey:@"Token"];
    
    // Your JSON data: {"user":{"Token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz"}}
    NSString *loginArray =[NSString stringWithFormat:@"{\"user\":{\"Token\":\"%@\"}}",reguserToken];
    NSLog(@"loginArray=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://qmswatch.kindlebit.com/API.asmx/CheckLicenseExpiryDate"]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    httpResponseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [httpResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [httpResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
    
    
    //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
    
    NSString * codeR = [dict[@"d"][@"ResponseCode"] stringValue];
    NSString * licenseExpiryDate = dict[@"d"][@"LicenseExpiryDate"];
      
    if ([codeR isEqualToString:@"200"]){
        NSUserDefaults *saveUserName = [NSUserDefaults standardUserDefaults];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *expiryDate = [dateFormat dateFromString:licenseExpiryDate];
        
        if ([[NSDate date] compare:expiryDate] == NSOrderedDescending) {
            //                    [saveUserName setObject:@(0) forKey:@"isLicenceValid"];
            [saveUserName setBool:NO forKey:@"isLicenceValid"];
        } else{
            //                    [saveUserName setObject:@(1) forKey:@"isLicenceValid"];
            [saveUserName setBool:YES forKey:@"isLicenceValid"];
        }
        [saveUserName synchronize];
    }
}

@end