//
//  HomeViewController.h
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface HomeViewController : UIViewController
{
    NSMutableData *httpResponseLicense,*httpResponseData;
    NSString *codeR, *codemsg,*licenseExpiryDate;
    UIAlertView *alertLogin,*alertfail;
    
  
    
    
    
    
}

@property (strong, nonatomic) IBOutlet UIButton *btnEnter;

- (IBAction)btnAboutQMSTapped:(id)sender;
- (void)checkUserLicenseExpiryDateFromService:(NSString *)userToken;

@property (strong, nonatomic) IBOutlet UILabel *lblLicenseExpiryDate;


//@property (retain, nonatomic) IBOutlet UITextField *name;
//@property (retain, nonatomic) IBOutlet UITextField *address;
//@property (retain, nonatomic) IBOutlet UITextField *phone;
//@property (retain, nonatomic) IBOutlet UILabel *status;
- (IBAction) saveData;
- (IBAction) findContact;

@end
