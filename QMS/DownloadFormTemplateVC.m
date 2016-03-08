//
//  DownloadFormTemplateVC.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//


#import "DownloadFormTemplateVC.h"
#import "DownloadFromTemp.h"
#import "TreeViewNode.h"
#import "TheProjectCell.h"
#import "DataFormVC.h"
#import "QMSTableViewDataSource.h"
#import "AppDelegate.h"


@interface DownloadFormTemplateVC ()
{
    NSUInteger indentation;
    NSMutableArray *nodes;
    IBOutlet QMSTableViewDataSource *tableViewDataSource;
    BOOL FlagCheck;
    QMSCurrentNetworkCall currentNetworkCall;
    NSTimer *timer;
    BOOL validationCheckDone;
    UIAlertView *alertfail;
    BOOL isDownloadingFile;
}

@property (nonatomic, retain) NSMutableArray *displayArray;

- (void)expandCollapseNode:(NSNotification *)notification;

- (void)fillDisplayArray;
- (void)fillNodeWithChildrenArray:(NSArray *)childrenArray;

- (void)fillNodesArray;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *fillChildrenForNode;

- (IBAction)expandAll:(id)sender;
- (IBAction)collapseAll:(id)sender;






@end

@implementation DownloadFormTemplateVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"DownloadFormTemplateVC" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"DownloadFormTemplateVC_iPad" bundle:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tableViewDataSource setTableViewSelectionType:kSSTableViewDataSourceSelectionTypeMultiple];
    
    
    // Do any additional setup after loading the view from its nib.
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(expandCollapseNode:) name:@"ProjectTreeNodeButtonClicked" object:nil];
    
    
     flagFrButton=YES;
    
    FlagCheck=YES;
    
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    FlagCheck = YES;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setTimer:YES];
    
    if (isDownloadingFile == NO) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self checkLoginAndGoForTemplate];
    }
}

-(void) setTimer:(BOOL) isSet{
    if (isSet == YES && isDownloadingFile == NO) {
        timer = [NSTimer scheduledTimerWithTimeInterval:30
                                                 target:self
                                               selector:@selector(checkLoginAndGoForTemplate)
                                               userInfo:nil
                                                repeats:YES];
    } else{
        [timer invalidate];
        timer = nil;
    }
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self setTimer:NO];
}

-(void) goToLoginScreen{
    if (validationCheckDone == NO) {
        AppDelegate *appDel = [AppDelegate sharedAppDelegate];
        validationCheckDone = ![appDel validateUser];
    } else{
        [self btnBackTapped:nil];
    }
}

-(void) checkLoginAndGoForTemplate{
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == NO) {
        [self goToLoginScreen];
    }
    else{
        NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
        BOOL licenseValid = [retriveUserToken boolForKey:@"isLicenceValid"];
        if (licenseValid == NO) {
            [timer invalidate];
            [self showLicenceExpiryMessage];
        } else{
            [self fetchTemplatesFromDB];
            [self getDownloadPDFTemplateFromService];
        }
    }
}

-(void) showLicenceExpiryMessage{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:@"License" message:@"QMS Watch license has expired. Visit QMSWatch.com to renew your license" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    alertViewForDeleteForms.tag = 501;
    [alertViewForDeleteForms show];
}

#pragma mark -- TableView datasourrce
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
             didSelectValue:(id) value{
    
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
           didDeSelectValue:(id) value{
    
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
       didSelectHeaderValue:(QMSTemplate*) value{
        [self getDownloadPDFTemplateByTemplateTypeId:reguserToken :[value valueForKey:@"templateTypeId"]];
}

-(void) fetchTemplatesFromDB{
    NSArray *templatesArray = [QMSTemplate getPersistentObjectsForKey:@"templateOwner"
                                                          havingValue:[QMSUser currentUser]];
//    if ([templatesArray count] == 0) {
//        
//    } else{
//        NSArray *selectedArray = [tableViewDataSource selectedValues];
        [tableViewDataSource setDataArray:templatesArray];
//        [tableViewDataSource selectValues:selectedArray];
//    }
}
#pragma mark Actions

- (IBAction)btnBackTapped:(id)sender {
   // [self.navigationController popViewControllerAnimated:YES];
    validationCheckDone = NO;
     NSLog(@"--Do Moving Right-------Data Form View");
    NSArray *vcArray = [self.navigationController viewControllers];
    __block BOOL isDataFormsExistInArray = NO;
    [vcArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[DataFormVC class]] == YES){
            isDataFormsExistInArray = YES;
        }
    }];
    if (isDataFormsExistInArray == YES) {
        [[self navigationController] popViewControllerAnimated:YES];
    } else{
        DataFormVC *dataFormVC=[[DataFormVC alloc]initWithNibName:@"DataFormVC" bundle:nil];
        [self.navigationController pushViewController:dataFormVC animated:NO];
    }
   
}

- (IBAction)btnDownloadNowTapped:(id)sender {
    [self downloadSelectedPDFFile];
   
}



#pragma mark WS



- (void)getDownloadPDFTemplateFromService{
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
        currentNetworkCall = kQMSCurrentNetworkCallGetTemplate;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
}


- (void)getDownloadPDFTemplateByTemplateTypeId:(NSString *)UserToken :(NSString *)templateTypeid
{
    // Start showing activity indicator.U
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == NO) {
        [self goToLoginScreen];
        return;
    }

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
  //  {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    // Your JSON data: {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    NSString *tempArray =[NSString stringWithFormat:@"{\"template\":{\"token\":\"%@\",\"TemplateTypeId\":\"%@\"}}",reguserToken,templateTypeid];
    NSLog(@"DownloadPDFTemplateByTemplateTypeId=%@", tempArray);
    
   
    
    // Encode the post string.
    NSData *postRequestData = [tempArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",DownloadPDFTemplateByTemplateTypeId]]];
    NSLog(@"%@",DownloadPDFTemplateByTemplateTypeId);
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        currentNetworkCall = kQMSCurrentNetworkCallGetPDFTemplate;
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
    httpResponseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
        if (currentNetworkCall == kQMSCurrentNetworkCallGetPDFTemplate) {
        
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseData length]);
        NSString *strr = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpResponseData options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
      
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
            
         
            secondMainTemplate = [[NSMutableArray alloc]init];
            secondMainTemplate = dict[@"d"][@"Templates"];
            
            
            NSLog(@"--secondMainTemplate::%@",secondMainTemplate);
            
        
            tempName =[secondMainTemplate valueForKey:@"TemplateName"];
            NSLog(@"--tempTypeName::%@",tempName);
            
            
            tempNameArr=[[NSMutableArray alloc]init];
            tempNameArr=[secondMainTemplate valueForKey:@"TemplateName"];
            
             NSLog(@"--tempNameArr::%@",tempNameArr);
            
            pdfTemplateIdArr=[[NSMutableArray alloc]init];
            pdfTemplateIdArr=[secondMainTemplate valueForKey:@"PDFTemplateId"];
            NSLog(@"--pdfTemplateIdArr::%@",pdfTemplateIdArr);
            
            
            
            // save user defaults
            NSUserDefaults *tempNameDefaults = [NSUserDefaults standardUserDefaults];
            [tempNameDefaults setObject:[secondMainTemplate valueForKey:@"TemplateName"] forKey:@"tempNameDefaults"];
            [tempNameDefaults synchronize];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSArray *tempNameD = [userDefaults objectForKey:@"tempNameDefaults"];
            NSLog(@"tempNameDefaults:%@",tempNameD);
            
            
            tempDownloadUrlArr=[[NSMutableArray alloc]init];
            tempDownloadUrlArr=[secondMainTemplate valueForKey:@"DownloadUrl"];
            
            NSLog(@"--tempDownloadUrlArr::%@",tempDownloadUrlArr);
            
            tempTypeArr=[[NSMutableArray alloc]init];
            tempTypeArr=[secondMainTemplate valueForKey:@"TemplateTypeName"];
            
           

            
            tempCreatedDateArr=[[NSMutableArray alloc]init];
            tempCreatedDateArr=[secondMainTemplate valueForKey:@"CreatedDate"];
            
            tempDownloadDateArr=[[NSMutableArray alloc]init];
            tempDownloadDateArr=[secondMainTemplate valueForKey:@"DownloadDate"];
         
            //modifiedDateArr, *isactiveArr,*pdfBase64Arr;
            
            modifiedDateArr=[[NSMutableArray alloc]init];
            modifiedDateArr=[secondMainTemplate valueForKey:@"ModifiedDate"];
            
            isactiveArr=[[NSMutableArray alloc]init];
            isactiveArr=[secondMainTemplate valueForKey:@"IsActive"];
            
            pdfBase64Arr=[[NSMutableArray alloc]init];
            pdfBase64Arr=[secondMainTemplate valueForKey:@"PDFBase64"];
            
            [secondMainTemplate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                QMSPDFTemplate *pdfTemplate = [QMSPDFTemplate newUnManagedObject];
                [pdfTemplate setDataObjectDictionary:obj];
                QMSPDFTemplate *persiTemplate = [QMSPDFTemplate getPersistentObject:pdfTemplate];
                if (persiTemplate == nil) {
                    [QMSCoreDataReusableMethod insertObjectIntoContext:pdfTemplate];
                    [QMSCoreDataReusableMethod saveContext];
                    [self fetchTemplatesFromDB];
                }
            }];

            
        }
        else
        {
            NSLog(@"----Nope");
               codeMsg = dict[@"d"][@"Message"];
          alertfail=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertfail show];
            
        }
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }
        
       
        
    }
    
    else if(currentNetworkCall == kQMSCurrentNetworkCallGetTemplate)
    {
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseData length]);
        NSString *strr = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        NSLog(@"--Done");
    
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
        

        
       codeR = [dict[@"d"][@"ResponseCode"] stringValue];
 
        

        maintemplist = [[NSMutableArray alloc]init];
        maintemplist = dict[@"d"][@"Templates"];
        

        __block  NSMutableArray *templatesArray = [[QMSTemplate getPersistentObjectsForKey:@"templateOwner"
                                                              havingValue:[QMSUser currentUser]] mutableCopy];
        
        NSLog(@"--maintemplist::%@",maintemplist);
        if (maintemplist != nil && [maintemplist isKindOfClass:[NSNull class]] == NO) {
            [maintemplist enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                QMSTemplate *template = [QMSTemplate newUnManagedObject];
                [template setDataObjectDictionary:obj];
                QMSTemplate *persiTemplate = [QMSTemplate getPersistentObject:template];
                if (persiTemplate == nil) {
                    [QMSCoreDataReusableMethod insertObjectIntoContext:template];
                    [template setTemplateOwner:[QMSUser currentUser]];
                    [QMSCoreDataReusableMethod saveContext];
                }
                [templatesArray removeObject:persiTemplate];
            }];
            
            
            [templatesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [[QMSCoreDataReusableMethod managedObjectContext] deleteObject:obj];
            }];
            [QMSCoreDataReusableMethod saveContext];
        }
        
        
        [self fetchTemplatesFromDB];
        
        tempTypeName =[maintemplist valueForKey:@"TemplateTypeName"];
        NSLog(@"--tempTypeName::%@",tempTypeName);
    
}

[MBProgressHUD hideHUDForView:self.view animated:YES];


}



- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    
    NSLog(@"willBeginSendingToApplication");
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    NSLog(@"didEndSendingToApplication");
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
    
}
- (IBAction)adobeButton {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"com.adobe.Adobe-Reader://Interactive_Collateral_Form.pdf"]];
}

-(void)openDocumentIn {
    NSString * filePath =
    [[NSBundle mainBundle]
     pathForResource:@"SampleTemplate" ofType:@"pdf"];
   UIDocumentInteractionController *documentController =
    [UIDocumentInteractionController
     interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    documentController.delegate = self;
   // [documentController retain];
    documentController.UTI = @"com.adobe.pdf";
    [documentController presentOpenInMenuFromRect:CGRectZero
                                           inView:self.view
                                         animated:YES];
}


#pragma mark -- New Code
-(void) downloadSelectedPDFFile{
    [self setTimer:NO];
    NSArray *selectedTemplaates = [tableViewDataSource selectedValues];
    if ([selectedTemplaates count] > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            __block NSMutableArray *failureFiles = [NSMutableArray array];
            isDownloadingFile = YES;
            [selectedTemplaates enumerateObjectsUsingBlock:^(QMSPDFTemplate* obj, NSUInteger idx, BOOL *stop) {
                //Background Thread
                NSString *urlString = [obj valueForKey:@"downloadUrl"];
                urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *urlLocal = [NSURL URLWithString:urlString];
                NSData *pdfFileFromUrl = [NSData dataWithContentsOfURL:urlLocal];
                NSString *pdfFileName = [obj fileName];
                if (pdfFileFromUrl != nil) {
                    [QMSCoreDataReusableMethod saveFile:pdfFileFromUrl
                                                 ofName:pdfFileName];
                    [obj setIsDownLoaded:@(1)];
                    [QMSCoreDataReusableMethod saveContext];
                } else{
                    [failureFiles addObject:pdfFileName];
                }
                
            }];
            NSLog(@"Download file work done");
            dispatch_async(dispatch_get_main_queue(), ^{
                isDownloadingFile = NO;
                [self fetchTemplatesFromDB];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([failureFiles count] == 0) {
                    [self showAlertForDownloadSuccessOfFile];
                }
                else if ([failureFiles count] == [selectedTemplaates count]){
                    [self showAlertForDownloadFailureAll];
                } else{
                    NSString *fileNames = [failureFiles componentsJoinedByString:@"\n"];
                    [self showAlertForDownloadFailureOfFiles:fileNames];
                }
                [self setTimer:YES];
            });
        });
        
    } else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No template to selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void) showAlertForDownloadSuccessOfFile{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Forms have been successfully downloaded"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showAlertForDownloadFailureOfFiles:(NSString*) failureFiles{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Following Forms failed to download\n%@",failureFiles] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showAlertForDownloadFailureAll{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Forms failed to download"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([[alertView message] isEqualToString:codeMsg]) {
    }
    else{
    [self performSelector:@selector(btnBackTapped:) withObject:nil afterDelay:0.2f];
    }
    
    
//    [self btnBackTapped:nil];
}
@end
