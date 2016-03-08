//
//  UploadFormDataVC.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "UploadFormDataVC.h"
#define kFileUploadScriptURL @"SERVER_ADDRESS/upload_file.php"

#import "QMSDataFormsTableViewDataSource.h"

#import "GTMBase64.h"
#import "GTMDefines.h"

#import "AFNetworking.h"

#import "NSData+Base64.h"
#import "AppDelegate.h"

@interface UploadFormDataVC (){
    IBOutlet QMSUploadDataFormsTableViewDataSource *tableViewDataSource;
    __block NSMutableDictionary *fileUploadStatus;
    NSNumber *uploadingStatusNo;
    
}

@end

@implementation UploadFormDataVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"UploadFormDataVC" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"UploadFormDataVC_iPad" bundle:nil];
        }
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableViewDataSource setTableViewSelectionType:kSSTableViewDataSourceSelectionTypeMultiple];
    fileUploadStatus = [NSMutableDictionary dictionary];
    uploadingStatusNo = @(10);
    
    // Do any additional setup after loading the view from its nib.
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
   
    [self.closebtn setHidden:YES];
    
    arrDownloadURl=[[NSMutableArray alloc]init];
    arrTempName=[[NSMutableArray alloc]init];
    arrTempCreateDate=[[NSMutableArray alloc]init];
    subtemplist = [[NSMutableArray alloc]init];
    arrTempNamesub=[[NSMutableArray alloc]init];
    
    
    
    
//    [self getDownloadPDFTemplateFromService:reguserToken];
    
   
    
    [_tabletreeView setFrame:CGRectMake(45 , 124, 289, 160)] ;
    [_tabletreeView setHidden:YES];
    
    flagFrButton=YES;
    
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [self.closebtn setHidden:YES];
    [self fetchDownloaedPDFTemplatesFromDB];
}

-(void) fetchDownloaedPDFTemplatesFromDB{
    
    NSArray *pdfTemplatesArray = [QMSPDFTemplate getPersistentObjectsForKey:@"isDownLoaded" havingValue:@(1)];
    if ([pdfTemplatesArray count] > 0) {
        NSArray *templatesArray = [QMSTemplate fetchAllObjects] ;
        __block NSMutableArray *filteredTemplatesArray = [NSMutableArray array];
        [pdfTemplatesArray enumerateObjectsUsingBlock:^( QMSPDFTemplate *obj, NSUInteger idx, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QMSTemplate* evaluatedObject, NSDictionary *bindings) {
                BOOL isExist= NO;
                if ([[evaluatedObject templateTypeId] isEqualToNumber:[obj templateTypeId]] == YES) {
                    if ([[obj getAllPdfTemplateCopy] count] > 0) {
                        isExist = YES;
                    }
                }
                return isExist;
            }];
            [filteredTemplatesArray addObjectsFromArray:[templatesArray filteredArrayUsingPredicate:predicate]];
        }];
        [tableViewDataSource setDataArray:filteredTemplatesArray];
    } 
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
    
}

-(void) downloadButtonPressed:(id)sender;{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBackTapped:(id)sender {
    
 [self.navigationController popViewControllerAnimated:YES];

}

-(void) goToLoginScreen{
    AppDelegate *appDel = [AppDelegate sharedAppDelegate];
    [appDel validateUser];
}

- (IBAction)btnUploadNowTapped:(id)sender {
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == NO) {
        [self goToLoginScreen];
    }
    else{
        [fileUploadStatus removeAllObjects];
        
        if ([[tableViewDataSource checkedPDFForms] count] == 0) {
            UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select atleast one file to upload" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //    alertViewForDeleteForms.tag = 501;
            [alertViewForDeleteForms show];
        } else{
            NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
            BOOL licenseValid = [retriveUserToken boolForKey:@"isLicenceValid"];
            if (licenseValid == NO) {
                [self showLicenceExpiryMessage];
            } else{
                [self doUploadNextFile];
            }
        }
    }
}

-(void) previousFileUploadSuccess{
    NSString *key = [self currentUplodingFileKey];
    NSNumber *value = [fileUploadStatus valueForKey:key];
    value = [NSNumber numberWithInteger:[value integerValue] + 1];
    [fileUploadStatus setValue:value forKey:key];
    [self doUploadNextFile];
}

-(void) previousFileUploadFailure{
    NSString *key = [self currentUplodingFileKey];
    NSNumber *value = [fileUploadStatus valueForKey:key];
    value = [NSNumber numberWithInteger:[value integerValue] + 2];
    [fileUploadStatus setValue:value forKey:key];
    [self doUploadNextFile];
}

-(void) doUploadNextFile{
    if ([fileUploadStatus count] == [[tableViewDataSource checkedPDFForms] count]) {
        [self handleFileUploadDone];
    } else{
        [[tableViewDataSource checkedPDFForms] enumerateObjectsUsingBlock:^(QMSPDFTemplateCopy * obj, NSUInteger idx, BOOL *stop) {
            
            NSNumber *uploadStatus = [fileUploadStatus valueForKey:[obj valueForKey:@"pdfTemplateCompleteDesc"]];
            if (uploadStatus == nil || [uploadStatus integerValue] < [uploadingStatusNo integerValue]) {
                [fileUploadStatus setValue:uploadingStatusNo forKey:[obj valueForKey:@"pdfTemplateCompleteDesc"]];
                
                NSData *data = [QMSCoreDataReusableMethod readFileOfName:[obj fileName] fromFolder:PDF_DATAFORMS_FOLDER];
                NSString *base64PDF = [data base64EncodedString];
                NSString *pdfname = [obj fileName];
                NSString *pdfTemplateId = [obj valueForKey:@"pdfTemplateId"];
                [self UploadPDFTemplateFile:base64PDF :reguserToken :pdfname:pdfTemplateId];
                *stop = YES;
            }
        }];
    }
}

-(NSString*) currentUplodingFileKey{
    __block NSString *upkey = @"";
    [fileUploadStatus enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToNumber:uploadingStatusNo] == YES) {
            upkey = key;
            *stop = YES;
        }
    }];
    return upkey;
}

-(void) handleFileUploadDone{
    __block NSMutableArray * failureFiles = [NSMutableArray array];
    [fileUploadStatus enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToNumber:@(12)] == YES) {
            [failureFiles addObject:key];
        }
    }];
    if ([failureFiles count] == 0) {
        [self showAlertForDownloadSuccessOfFile];
    }
    else if ([failureFiles count] == [[tableViewDataSource checkedPDFForms] count]){
        [self showAlertForDownloadFailureAll];
    } else{
        NSString *fileNames = [failureFiles componentsJoinedByString:@"\n"];
        [self showAlertForDownloadFailureOfFiles:fileNames];
    }
}

-(void) showAlertForDownloadSuccessOfFile{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Forms have been successfully uploaded"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showAlertForDownloadFailureOfFiles:(NSString*) failureFiles{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Following Forms failed to upload\n%@",failureFiles] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showAlertForDownloadFailureAll{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Forms failed to upload"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showLicenceExpiryMessage{
    UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:@"License" message:@"QMS Watch license has expired. Visit QMSWatch.com to renew your license" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    alertViewForDeleteForms.tag = 501;
    [alertViewForDeleteForms show];
}


#pragma mark WS
- (void)downloadPDFTemplateFile:(NSString *)UserToken :(NSString *)templateTypeid //secodn
{
    
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    // {"token":"ba87b75b-67e9-4e4e-85df-62df307cdce1j6mNI7P4", "pdfTemplateId":"34"}
    // Your JSON data: {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    NSString *tempArray =[NSString stringWithFormat:@"{\"token\":\"%@\",\"pdfTemplateId\":\"%@\"}",reguserToken,templateTypeid];
    NSLog(@"downloadPDFTemplateFile=%@", tempArray);
    
    
    
    // Encode the post string.
    NSData *postRequestData = [tempArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",DownloadTemplateFile]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpDownloadTempFile = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    
}

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


- (void)getDownloadPDFTemplateByTemplateTypeId:(NSString *)UserToken :(NSString *)templateTypeid
{
    // Start showing activity indicator.U
    
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
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpTemplateTypeId = [[NSMutableData alloc] init];
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
    [httpTemplateTypeId setLength:0];
    [httpDownloadTemp setLength:0];
    [httpDownloadTempFile setLength:0];
    [httpUploadpdf setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpResponseData appendData:data];
    [httpTemplateTypeId appendData:data];
    [httpDownloadTemp appendData:data];
    [httpDownloadTempFile appendData:data];
    
    [httpUploadpdf appendData:data];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (httpUploadpdf) {
        [self previousFileUploadFailure];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
   if (httpTemplateTypeId) {
        
        
        
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpTemplateTypeId length]);
        NSString *strr = [[NSString alloc] initWithData:httpTemplateTypeId encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpTemplateTypeId options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpTemplateTypeId options:NSJSONReadingMutableLeaves error:nil];
       
     
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
            
            [_tabletreeView setHidden:NO];
            
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
            
            
            tempDownloadUrlArr=[[NSMutableArray alloc]init];
            tempDownloadUrlArr=[secondMainTemplate valueForKey:@"DownloadUrl"];
            
            
            
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
         //   pdfBase64Arr=[secondMainTemplate valueForKey:@"PDFBase64"];
            
            [_tabletreeView reloadData];
            
            
            
        }
        else
        {
            NSLog(@"----Nope");
            codeMsg = dict[@"d"][@"Message"];
            [_tabletreeView setHidden:YES];
            
            UIAlertView * alertfail=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertfail show];
            
        }
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }
       
   ///   [self downloadPDFTemplate:reguserToken :pdfTempId];
       
       httpTemplateTypeId=nil;
    }

    
  else if (httpDownloadTempFile) {
        
           
         
           
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpDownloadTempFile length]);
        NSString *strr = [[NSString alloc] initWithData:httpDownloadTempFile encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpDownloadTempFile options:NSJSONReadingAllowFragments error:&e];
       
    
      
//      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//      NSString *documentsDirectory = [paths objectAtIndex:0];
//      NSString *file = [documentsDirectory stringByAppendingPathComponent:@"MyDocument.pdf"];
//      
//  //    NSData *pdfData = ... // data representing your created PDF
//      NSError *error = nil;
//      if ([httpDownloadTempFile writeToFile:file options:NSDataWritingAtomic error:& error]) {
//          // file saved
//          NSLog(@"----file saved");
      
//          NSData *someData=[NSData dataWithContentsOfFile:file];
//          
//          base64file = [someData base64EncodedString];
//          
//          NSLog(@"--base64file::%@",base64file);
          
          
//          NSMutableData *saveData = [NSMutableData data];
//          
//          binaryFile = [documentsDirectory stringByAppendingPathComponent:@"MyDocument.pdf"];
//          binaryData = [NSData dataWithContentsOfFile:binaryFile];
//          
//          [saveData appendBytes:[binaryData bytes] length:binaryData.length];
//          
//          
//          NSLog(@"--binaryData::%@",binaryData);
          //store another data
        //  [saveData writeToFile:@"mySave" atomically:YES];
          
          
//      } else {
//          // error writing file
//          NSLog(@"Unable to write PDF to %@. Error: %@", file, error);
//      }
      
      
           [_webviewshowpdf setHidden:NO];
           
           [_tabletreeView setHidden:YES];
           
           [self.closebtn setHidden:NO];
           
          [_webviewshowpdf loadData:httpDownloadTempFile MIMEType: @"application/pdf" textEncodingName: @"UTF-8" baseURL:nil];
      
      
//      ///base 64
//      NSData *someData=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kk2" ofType:@"jpeg"]];
//      
//      base64file = [someData base64EncodedString];
//      
//      NSLog(@"--base64file::%@",base64file);
//      //decode it
//      NSData *back = [NSData dataFromBase64String:base64file];
//      NSLog(@"--base64file::%@",back);
//      
      
      
      
      
//        if (!jsonArray) {
//            NSLog(@"Error parsing JSON: %@", e);
//        }
  
     httpDownloadTempFile=nil;
    }
    
   else if (httpDownloadTemp) {
        
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpDownloadTemp length]);
        NSString *strr = [[NSString alloc] initWithData:httpDownloadTemp encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpDownloadTemp options:NSJSONReadingMutableContainers error:&e];
       
     
       
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpDownloadTemp options:NSJSONReadingMutableLeaves error:nil];
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        
        codeMsg = dict[@"d"][@"Message"];
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
        }
        else
        {
             NSLog(@"----Nope");
            
        }

        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }
     
     
       
       
    //   httpDownloadTemp=nil;
   }
    
    else if(httpResponseData)
    {
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseData length]);
        NSString *strr = [[NSString alloc] initWithData:httpResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        
        NSLog(@"--Done");
        
        //  NSError *e = nil;
        //        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpResponseData options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseData options:NSJSONReadingMutableLeaves error:nil];
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        
        
        
        maintemplist = [[NSMutableArray alloc]init];
        maintemplist = dict[@"d"][@"Templates"];
        
        
        NSLog(@"--maintemplist::%@",maintemplist);
        
        
        tempTypeName =[maintemplist valueForKey:@"TemplateTypeName"];
        NSLog(@"--tempTypeName::%@",tempTypeName);
        
        
        
        tempIDvalue=[maintemplist valueForKey:@"TemplateTypeId"];
        NSLog(@"--tempIDvalue::%@",tempIDvalue);
        

        
        
        if (maintemplist.count) {
            
            
            for (int i=0; i<maintemplist.count; i++)
            {
                
                ///allocate UIBUTTON dynamically here on the basis of count of temptypes
                
                UIButton*    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                
                [button setFrame:CGRectMake(45 , 111 + (i*35), 200, 30)];
                
                [button setTitle:[maintemplist valueForKey:@"TemplateTypeName"][i] forState:UIControlStateNormal];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                button.tag=[[maintemplist valueForKey:@"TemplateTypeId"][i]integerValue];
                
                
                
                
                NSLog(@"----button.tag::%ld",(long)button.tag);
                [[self view] addSubview:button];
                ////image for UIbutton
                
                UIButton *imgbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                
                [imgbutton setFrame:CGRectMake(12 , 114 + (i*35), 22, 21)];
                [imgbutton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
                
                //  [button setTitle:[[maintemplist valueForKey:@"TemplateTypeName"]objectAtIndex:i] forState:UIControlStateNormal];
                imgbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                [imgbutton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [[self view] addSubview:imgbutton];
                
                
                NSLog(@"---Total templist Data::%@",[maintemplist valueForKey:@"TemplateTypeName"][i]);
                NSLog(@"---Total TemplateTypeId::%@",[maintemplist valueForKey:@"TemplateTypeId"][i]);
                
                
            }
            
        }
        
        
        httpResponseData=nil;
    }
    
    else if (httpUploadpdf)
    {
        NSLog(@"connectionDidFinishLoading--httpUploadpdf");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpUploadpdf length]);
        NSString *strr = [[NSString alloc] initWithData:httpUploadpdf encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpUploadpdf options:NSJSONReadingMutableContainers error:&e];
        
        
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpUploadpdf options:NSJSONReadingMutableLeaves error:nil];
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        
        codeMsg = dict[@"d"][@"Message"];
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
            [self previousFileUploadSuccess];
//            UIAlertView * alertSuccess=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertSuccess show];

        }
        else
        {
            NSLog(@"----Nope");
            [self previousFileUploadFailure];
            
            codeMsg = dict[@"d"][@"Message"];
            [_tabletreeView setHidden:YES];
//            
//            UIAlertView * alertfail=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertfail show];

            
        }
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        }

    }
    
   
}


- (void)buttonPressed:(UIButton*)button
{
    NSLog(@"Button %ld clicked.", (long int)[button tag]);
    NSString * tempTypeButton=[NSString stringWithFormat:@"%ld", (long int)[button tag]];
    NSLog(@"tempTypeButton==%@", tempTypeButton);
    
    buttonTempTag=(int)[button tag];
    
    
    [self getDownloadPDFTemplateByTemplateTypeId:reguserToken :tempTypeButton];
    
    
    NSLog(@"---buttonPressed::%d",buttonTempTag);
    
    
    [_tabletreeView setFrame:CGRectMake(45 , 124 + (buttonTempTag*17), 289, 160)] ;

   
}



#pragma mark TableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return tempNameArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"DownloadFromTemp";
    DownloadFromTemp *cell = (DownloadFromTemp *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DownloadFromTemp" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (DownloadFromTemp *)currentObject;
                break;
            }
        }
    }
    
    
    [_tabletreeView setFrame:CGRectMake(45 , 124 + (buttonTempTag*17), 289, 160)] ;
    
    
    if (secondMainTemplate.count) {
        
        tempName =[secondMainTemplate valueForKey:@"TemplateName"];
        NSLog(@"--tempTypeName in cell::%@",tempName);
        
        pdfName=[NSString stringWithFormat:@"%@",tempNameArr[indexPath.row]];
        cell.TempName.text=[NSString stringWithFormat:@"%@",tempNameArr[indexPath.row]];
        
        
        tempUrl=[NSString stringWithFormat:@"%@",tempDownloadUrlArr[indexPath.row]];
        NSLog(@"--tempUrl::%@",tempUrl);
        
        //,*tempCreatedDateArr, *tempDownloadDateArr ,* tempTypeArr;
        createddatestr=[NSString stringWithFormat:@"%@",tempCreatedDateArr[indexPath.row]];
        NSLog(@"--createddatestr::%@",createddatestr);
        
        pdftypestr=[NSString stringWithFormat:@"%@",tempTypeArr[indexPath.row]];
        NSLog(@"--pdftypestr::%@",pdftypestr);
        
        downloaddatestr=[NSString stringWithFormat:@"%@",tempDownloadDateArr[indexPath.row]];
        NSLog(@"--downloaddatestr::%@",downloaddatestr);
        
        
        updatedatestr=[NSString stringWithFormat:@"%@",modifiedDateArr[indexPath.row]];
        NSLog(@"--updatedatestr::%@",updatedatestr);
        
        checkAvailbilitystr=[NSString stringWithFormat:@"%@",isactiveArr[indexPath.row]];
        NSLog(@"--checkAvailbilitystr::%@",checkAvailbilitystr);
        
     //   pdfBase64str=[NSString stringWithFormat:@"%@",[pdfBase64Arr objectAtIndex:indexPath.row]];
     //   NSLog(@"--pdfBase64str::%@",pdfBase64str);
        
       
        
        //download the file in a seperate thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            
            
            NSString *urlToDownload = tempUrl;
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if (urlData)
            {
                NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = paths[0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,pdfName];
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved !");
                    
                    NSData *someData=[NSData dataWithContentsOfFile:filePath];
                    
                    base64file = [someData base64EncodedString];
                    
                    NSLog(@"--base64file::%@",base64file);

                });
            }
            
        });

        
        
        
        
        [cell.btnCheckedTapped addTarget:self action:@selector(btnCheckedTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
//        //check file is downloded or not
//        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        tileDirectory = [documentdir stringByAppendingPathComponent:tempUrl];
//        NSLog(@"Downloded file ---Tile Directory: %@", tileDirectory);
//        
//        if (!tileDirectory) {
//            [cell.btnFindPdfAvailableInPhone setHidden:NO];
//             NSLog(@"-----File not Downloded----");
//        }
    }
    
    
    return cell;
}


-(void)btnCheckedTapped:(UIButton*)sender
{
        int j;
        
        for (j=0; j<secondMainTemplate.count; j++) {
            
            if (sender.tag == j)
            {
                //call webservice for new
                NSLog(@"for Tag 0------NewButtonTapped::%d",j);
                
                /// to get pdf id for upload
                pdfTempId=[NSString stringWithFormat:@"%@",pdfTemplateIdArr[j]];
                NSLog(@"--pdfTempId::%@",pdfTempId);
                                             
                pdfName= [NSString stringWithFormat:@"%@",tempNameArr[j]];
                 NSLog(@"--pdfName::%@",pdfName);
                           
               
                
                
            }
        }
            
   // [self downloadPDFTemplateFile:reguserToken :pdfTempId];
                      
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tempSelectedArr;
    tempSelectedArr =[[NSMutableArray alloc]init];
    
 
    if (secondMainTemplate.count) {
        
        
        tempUrl=[NSString stringWithFormat:@"%@",tempDownloadUrlArr[indexPath.row]];
        NSLog(@"--tempUrl::%@",tempUrl);
        
        
        pdfTempId=[NSString stringWithFormat:@"%@",pdfTemplateIdArr[indexPath.row]];
        NSLog(@"--pdfTempId::%@",pdfTempId);
        
    }
    
    NSLog(@"--tempSelectedArr::%@",tempSelectedArr);
    
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



#pragma mark WS for UploadPdf
- (void)UploadPDFTemplateFile:(NSString *)pdfBase64 :(NSString *)token :(NSString *)fileName :(NSString *)templateId
{
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
//    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    

    
    //{"base64":"base64 data", "token":"6d7fecef-c993-49c5-9177-2fd24fac6657aQmUICYS", "fileName":"thisisnew", "templateId":"34"}
    
    
    
    NSString *tempArray =[NSString stringWithFormat:@"{\"base64\":\"%@\",\"token\":\"%@\",\"fileName\":\"%@\",\"templateId\":\"%@\"}",pdfBase64,reguserToken,fileName,templateId];
    
//    NSLog(@"downloadPDFTemplateFile=%@", tempArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [tempArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",UploadPDFDataFormBase64]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpUploadpdf = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    
}



- (IBAction)btnCloseTapped:(id)sender {
    
    [self.webviewshowpdf setHidden:YES];
    [self.closebtn setHidden:YES];
}

@end
