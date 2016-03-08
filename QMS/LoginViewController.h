//
//  LoginViewController.h
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,NSURLConnectionDataDelegate>
{
    HomeViewController *homeVC;
    NSMutableData *httpResponseData;
    NSString *codeR, *codemsg,*userToken;
    UIAlertView *alertLogin,*alertfail;
}


@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *myTextFields;

- (IBAction)btnLoginTapped:(id)sender;

- (void)getUserLoginFromService:(NSString *)regUserName :(NSString *)password;

@end
