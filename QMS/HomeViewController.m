//
//  HomeViewController.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "HomeViewController.h"
#import "AboutViewController.h"
#import "DownloadFormTemplateVC.h"
#import "DataFormVC.h"
#import"MBProgressHUD.h"
#import "MainMenuViewController.h"

#import <sqlite3.h>



@interface HomeViewController ()
{
    NSString *reguserToken;
}
@end

@implementation HomeViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
  
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                //Use iPhone5 VC
                self = [super initWithNibName:@"HomeViewController" bundle:nil];
            }
            else{
                //Use Default VC
                self = [super initWithNibName:@"HomeViewController_iPad" bundle:nil];
            }
}
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
  [self performSelector:@selector(GotoNext) withObject:self afterDelay:5.0 ];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
   reguserToken = [retriveUserToken stringForKey:@"Token"];
   NSLog(@"----regUserToken ::%@",reguserToken);
    
    [self checkUserLicenseExpiryDateFromService:reguserToken];
    
   
    
//    //........towards right Gesture recogniser for swiping.....//
//    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
//    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [rightRecognizer setNumberOfTouchesRequired:1];
//    [self.view addGestureRecognizer:rightRecognizer];
//   
//    
//    //........towards left Gesture recogniser for swiping.....//
//    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
//    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [leftRecognizer setNumberOfTouchesRequired:1];
//    [self.view addGestureRecognizer:leftRecognizer];
   

    ///Check for PDF Template is empty or Not.. if yes then navigate to Download from template else to Data form
//    [self createTable];
//    [self getDbFilePath];
   
    
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do moving
    NSLog(@"--Do Moving Right-------Data Form View");
    
    MainMenuViewController *dataFormVC=[[MainMenuViewController alloc]initWithNibName:@"MainMenuViewController" bundle:nil];
    [self.navigationController pushViewController:dataFormVC animated:NO];
}

- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self GotoNext];
}


- (IBAction)btnEnter_TouchDown:(id)sender {
    
    [self GotoNext];
}





- (void)GotoNext
{

if ([self isFormsAvailable] == YES) {
    MainMenuViewController *dataFormVC=[[MainMenuViewController alloc]initWithNibName:@"MainMenuViewController" bundle:nil];
    [self.navigationController pushViewController:dataFormVC animated:NO];
 } else{
    // do moving
    NSLog(@"--Do Moving Left------------Download Form Template Form");
    MainMenuViewController *downloadFormTempVC=[[MainMenuViewController alloc]initWithNibName:@"MainMenuViewController" bundle:nil];
    [self.navigationController pushViewController:downloadFormTempVC animated:NO];
 }
}


-(BOOL) isFormsAvailable{
    NSFetchRequest *fetchRequest = [QMSPDFTemplate fetchRequestForKey:@"isDownLoaded" havingValue:@(1)];
    NSInteger count = [QMSCoreDataReusableMethod countForFetchRequest:fetchRequest];
    return count > 0;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnAboutQMSTapped:(id)sender {
    
    AboutViewController *aboutVC=[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)checkUserLicenseExpiryDateFromService:(NSString *)userToken
{
    // Start showing activity indicator.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    // Your JSON data: {"user":{"Token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz"}}
    NSString *loginArray =[NSString stringWithFormat:@"{\"user\":{\"Token\":\"%@\"}}",reguserToken];
    NSLog(@"loginArray=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",CheckLicenseExpiryDate]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpResponseLicense = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [httpResponseData setLength:0];
    [httpResponseLicense setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpResponseData appendData:data];
    [httpResponseLicense appendData:data];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (httpResponseData)
    {
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseData length]);
        NSString *strr = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        NSLog(@"data is: %@",httpResponseData);
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpResponseData options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
        
        
    //d:{"ResponseCode": 200,"Message": "License Not Expired","IsLicenseExpired": false,"LicenseExpiryDate": "15/03/2015","TokenStatus": "Valid Token"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
     
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
         //   _lblLicenseExpiryDate.text=licenseExpiryDate;
            
//            //........towards right Gesture recogniser for swiping.....//
//            UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
//            rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//            [rightRecognizer setNumberOfTouchesRequired:1];
//            [self.view addGestureRecognizer:rightRecognizer];
            
            
            //........towards left Gesture recogniser for swiping.....//
            UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
            leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [leftRecognizer setNumberOfTouchesRequired:1];
            [self.view addGestureRecognizer:leftRecognizer];
//
//            NSLog(@"--Do Moving Right-------Data Form View");
//            
//            DataFormVC *dataFormVC=[[DataFormVC alloc]initWithNibName:@"DataFormVC" bundle:nil];
//            [self.navigationController pushViewController:dataFormVC animated:NO];
            
//            NSLog(@"--Do Moving Left------------Download Form Template Form");
//            DownloadFormTemplateVC *downloadFormTempVC=[[DownloadFormTemplateVC alloc]initWithNibName:@"DownloadFormTemplateVC" bundle:nil];
//            [self.navigationController pushViewController:downloadFormTempVC animated:NO];
            
    
        }
        else
        {
            NSLog(@"----Nope");
          
            
            
        }
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }
        
        httpResponseData=nil;
        
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    else if (httpResponseLicense)
    {
        
            NSLog(@"connectionDidFinishLoading");
            NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseLicense length]);
            NSString *strr = [[NSString alloc] initWithData:httpResponseLicense encoding:NSUTF8StringEncoding];
            NSLog(@"strr is: %@",strr);
            NSLog(@"data is: %@",httpResponseLicense);
            
            // convert to JSON
            
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpResponseLicense options:NSJSONReadingMutableContainers error:&e];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseLicense options:NSJSONReadingMutableLeaves error:nil];
            
            
            //d:{"ResponseCode": 200,"Message": "License Not Expired","IsLicenseExpired": false,"LicenseExpiryDate": "15/03/2015","TokenStatus": "Valid Token"}
            
            codeR = [dict[@"d"][@"ResponseCode"] stringValue];
            licenseExpiryDate = dict[@"d"][@"LicenseExpiryDate"];
            codemsg=dict[@"d"][@"Message"];
            
            if ([codeR isEqualToString:@"200"] || 1)
            {
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
                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:licenseExpiryDate message:[NSString stringWithFormat:@"%d",[saveUserName boolForKey:@"isLicenceValid"]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alertView show];
                
                NSLog(@"--Done");
                _lblLicenseExpiryDate.text=licenseExpiryDate;
                
//                //........towards right Gesture recogniser for swiping.....//
//                UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
//                rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//                [rightRecognizer setNumberOfTouchesRequired:1];
//                [self.view addGestureRecognizer:rightRecognizer];
//                
//                
//                //........towards left Gesture recogniser for swiping.....//
//                UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
//                leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//                [leftRecognizer setNumberOfTouchesRequired:1];
//                [self.view addGestureRecognizer:leftRecognizer];
                
               [self getDownloadPDFTemplateFromService:reguserToken];
                
            }
            else
            {
                NSLog(@"----Nope");
                
                _lblLicenseExpiryDate.text=codemsg;
                UIAlertView *alertLicense=[[UIAlertView alloc]initWithTitle:@"License Expired!" message:@"Please renew your license" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertLicense show];
            }
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", e);
            }
            
            httpResponseLicense=nil;
        
    }
    
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}


#pragma mark WS to check DB is available
- (void)getDownloadPDFTemplateFromService:(NSString *)UserToken
{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    // Your JSON data: {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz"}}
    NSString *loginArray =[NSString stringWithFormat:@"{\"template\":{\"token\":\"%@\"}}",reguserToken];
    NSLog(@"loginArray=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",DownloadPDFTemplateTypes]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpResponseData = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
}





@end
