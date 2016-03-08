//
//  LoginViewController.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import"MBProgressHUD.h"


@interface LoginViewController (){
    IBOutlet NSLayoutConstraint *headerHeightConstraints;
}

@end

@implementation LoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"LoginViewController" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"LoginViewController_iPad" bundle:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
    _txtUserName.delegate=self;
    _txtPassword.delegate=self;
    
    
    //for UI left Padding
    for (int i = 0; i < self.myTextFields.count; i++) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        UITextField *myField = (self.myTextFields)[i];
        
        paddingView.backgroundColor = [UIColor clearColor];
        myField.leftView = paddingView;
        myField.leftViewMode = UITextFieldViewModeAlways;
    }
    

   
//  _txtUserName.text=@"tesuser123";
//  _txtPassword.text=@"tesuser123";
//    _txtUserName.text=@"test";
//    _txtPassword.text=@"test123";
    _txtUserName.text=@"vjayrana";
    _txtPassword.text=@"abc@12345";
    
//    _txtUserName.text=@"test07";
//    _txtPassword.text=@"test&07";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self navigationController] != nil) {
        [headerHeightConstraints setConstant:0];
    }
}

- (IBAction)btnLoginTapped:(id)sender {
    
    
    if ([_txtPassword.text isEqualToString: @"" ] || [_txtUserName.text isEqualToString:@""]) {
        
        UIAlertView *errorAlert=[[UIAlertView alloc]initWithTitle:@"Login" message:@"Fields can not be blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else
    {
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // webservice for login
    [self getUserLoginFromService:_txtUserName.text :_txtPassword.text];
    }
    
}

-(IBAction) btnCancelTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUserLoginFromService:(NSString *)regUserName :(NSString *)password
{
    // Start showing activity indicator.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    regUserName=_txtUserName.text;
    password=_txtPassword.text;
    
    
        NSUserDefaults *saveUserName = [NSUserDefaults standardUserDefaults];
        [saveUserName setObject:regUserName forKey:@"regUserName"];
    
    
    // Your JSON data: {"user":{"UserName":"TestUserName3", "Password":"TestPassword3"}}
    NSString *loginArray =[NSString stringWithFormat:@"{\"user\":{\"UserName\":\"%@\",\"Password\":\"%@\"}}",regUserName,password];
    NSLog(@"loginArray=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",AuthenticateUser]]];
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


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [httpResponseData setLength:0];
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpResponseData appendData:data];
   
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not connect to server please try again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
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
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        codemsg = dict[@"d"][@"Message"];
        userToken=dict[@"d"][@"Token"];
        
        
        //saving Token
        NSUserDefaults *saveUserToken = [NSUserDefaults standardUserDefaults];
        [saveUserToken setObject:userToken forKey:@"Token"];
        [saveUserToken synchronize];
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
//            alertLogin=[[UIAlertView alloc]initWithTitle:@"Login" message:codemsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertLogin show];
            QMSUser *user = [QMSUser newUnManagedObject];
            [user setUserName:_txtUserName.text];
            [user setPassword:_txtPassword.text];
            [user setToken:userToken];
            [QMSUser saveUser:user];
            [self doLogin];
            [QMSCoreDataReusableMethod saveToUserDefaults:@"isLoggedIn" value:@(1)];
        }
        else
        {
            NSLog(@"----Nope");
            alertfail=[[UIAlertView alloc]initWithTitle:@"Login" message:codemsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertfail show];
            
        }
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }
    }
  
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void) doLogin{
    if (self.navigationController == nil) {
        [self btnCancelTapped:nil];
    } else{
        // if sucess.. navigate to home screen
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            homeVC=[[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        }
        else
        {
            homeVC=[[HomeViewController alloc]initWithNibName:@"HomeViewController_iPad" bundle:nil];
        }
        [self.navigationController pushViewController:homeVC animated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(alertView==alertLogin)
    {
        if (buttonIndex == 0)
        {
            
        }
        if (buttonIndex == 1)
        {
            //Code for cancel button
        }
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

#pragma mark TextField delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    
//    return true;
//}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    CGRect viewFrame = self.view.frame;
    CGFloat newY = 40;
    viewFrame = CGRectMake(CGRectGetMinX(viewFrame), CGRectGetMinY(viewFrame)-newY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    [UIView animateWithDuration:0.33f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect viewFrame = self.view.frame;
    CGFloat newY = 40;
    viewFrame = CGRectMake(CGRectGetMinX(viewFrame), CGRectGetMinY(viewFrame)+newY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    [UIView animateWithDuration:0.33f animations:^{
        [self.view setFrame:viewFrame];
    }];
}

@end
