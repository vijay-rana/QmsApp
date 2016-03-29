//
//  DataFormVC.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "DataFormVC.h"
#import "AboutViewController.h"
#import "UploadFormDataVC.h"
#import "DownloadFormTemplateVC.h"

#import"MBProgressHUD.h"
#import "DataFormsCustom.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "TreeViewNode.h"
#import "TheProjectCell.h"
#import "DataFormVC.h"
#import "QMSTableViewDataSource.h"
#import "QMSPDFViewController.h"
#import <MessageUI/MessageUI.h>

#import "QMSDataFormDescEditorViewController.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"


@interface DataFormVC ()<MFMailComposeViewControllerDelegate>
{
    NSUInteger indentation;
    NSMutableArray *nodes;
    
    BOOL FlagCheck;
    IBOutlet QMSTableViewDataSource *tableViewDataSource;
    QMSPDFTemplate *currentSelectedPDFTemplate;
    QMSPDFTemplateCopy *currentSelectedPDFTemplateCopy;
    PDFViewController *_pdfViewController;
    IBOutlet UIView* overlayView;
    IBOutlet UILabel* logoutLabel;
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

@implementation DataFormVC

bool isShown = false; //for toggle of view

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"DataFormVC" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"DataFormVC_iPad" bundle:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentSelectedPDFTemplate = nil;
    
    NSString *CellIdentifier = @"treeNodeCell";
    UINib *nib = [UINib nibWithNibName:@"ProjectCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    NSString *childCellIdentifier = @"QMSTreenodeTableChildCell";
    UINib *nib2 = [UINib nibWithNibName:childCellIdentifier bundle:nil];
    [_tableView registerNib:nib2 forCellReuseIdentifier:childCellIdentifier];
    
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(expandCollapseNode:) name:@"ProjectTreeNodeButtonClicked" object:nil];
    
    
    [_tabletreeView reloadData];
    
    [self.websubview setHidden:YES];
    
    arrDownloadURl=[[NSMutableArray alloc]init];
    arrTempName=[[NSMutableArray alloc]init];
    arrTempCreateDate=[[NSMutableArray alloc]init];
    subtemplist = [[NSMutableArray alloc]init];
    arrTempNamesub=[[NSMutableArray alloc]init];
    
    
     arryfornew=[[NSMutableArray alloc]init];
    
//    [self getDownloadPDFTemplateFromService:reguserToken];
    //commented as need without internet
    
    
    [_tabletreeView setFrame:CGRectMake(45 , 124, 289, 160)];
    [_tabletreeView setHidden:YES];
    
    flagFrButton=YES;
    
    
    ////////////////////////////////////////////////////////////
   [self.sidePanelView setHidden:YES];
    isShown = true;
     [_btnsidePanel setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    FlagCheck=YES;
    [self fetchDownloaedPDFTemplatesFromDB];
    [[self navigationController ] setNavigationBarHidden:YES];
    [[tableViewDataSource tableView] reloadData];
    
    [self setLogoutBtnLabel];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self hideSlider:nil];
}

-(void) setLogoutBtnLabel{
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == YES) {
        [logoutLabel setText:@"Logout"];
    } else{
        [logoutLabel setText:@"Login"];
    }
}

-(void) redirectToLoginVC{
    AppDelegate *appDel = [AppDelegate sharedAppDelegate];
    [appDel validateUser];
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
                    isExist = YES;
                }
                return isExist;
            }];
            [filteredTemplatesArray addObjectsFromArray:[templatesArray filteredArrayUsingPredicate:predicate]];
        }];
        [tableViewDataSource setDataArray:filteredTemplatesArray];
    } else{
        [self showAlertForNoDataForms];
    }

}

-(void) showAlertForNoDataForms{
    UIAlertView *alertViewForNoForms = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Template forms are required,\nproceed to the Download page"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    alertViewForNoForms.tag = 404;
    [alertViewForNoForms show];
}

-(void) createPDFDataFormsWithDiscription:(NSString*) desc{
    if ([self isNameExist:desc] == NO) {
        QMSPDFTemplateCopy *pdfTemplateCopy = [QMSPDFTemplateCopy newManagedObject];
        [pdfTemplateCopy setCreationDateTime:[NSDate date]];
        [pdfTemplateCopy setPdfTemplateDescription:desc];
        [pdfTemplateCopy setPdfTemplateId:[currentSelectedPDFTemplate valueForKey:@"pdfTemplateId"]];
        [QMSCoreDataReusableMethod saveContext];
        [[tableViewDataSource tableView] reloadData];
        
        NSData *data = [QMSCoreDataReusableMethod readFileOfName:[currentSelectedPDFTemplate fileName]];
        [QMSCoreDataReusableMethod saveFile:data
                                     ofName:[pdfTemplateCopy fileName]
                                 intoFolder:PDF_DATAFORMS_FOLDER];
    }
}

-(void) renamePDFDataFormsFileWithNewDiscription:(NSString*) desc{
    //Rename in core data as well actual pdf file name.
    
    QMSPDFTemplateCopy *pdfTemplateCopy = currentSelectedPDFTemplateCopy;
    NSString *oldFilePath = [QMSCoreDataReusableMethod filePathForFileName:[pdfTemplateCopy fileName] withFolderName:PDF_DATAFORMS_FOLDER];
    [pdfTemplateCopy setPdfTemplateDescription:desc];
    [pdfTemplateCopy setCreationDateTime:[NSDate date]];
    [QMSCoreDataReusableMethod saveContext];
    [[tableViewDataSource tableView] reloadData];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    NSString *newFilePath = [QMSCoreDataReusableMethod filePathForFileName:[pdfTemplateCopy fileName] withFolderName:PDF_DATAFORMS_FOLDER];
    if([fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error] == NO){
        NSLog(@"Error in renaming pdf data froms %@",[error localizedDescription]);
    }
    
}

#pragma mark -- TableView datasourrce
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
             didSelectValue:(id) value{
    
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
 didTouchedOnNewPDFForValue:(id) value{
    currentSelectedPDFTemplate = value;
    [self showAlertForNewPDFForValue:currentSelectedPDFTemplate withMessage:@"Please Enter Description"];
}

-(void) showAlertForNewPDFForValue:(id) value withMessage:(NSString*) message{
    UIAlertView *alertViewForNewForms = [[UIAlertView alloc] initWithTitle:[QMSTableViewDataSource _textFromValue:value] message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertViewForNewForms.tag = 500;
    [alertViewForNewForms setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertViewForNewForms show];
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
didTouchedOnDeletePDFTemplate:(id) value{
    currentSelectedPDFTemplate = value;
    UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:[QMSTableViewDataSource _textFromValue:value] message:@"Are you sure want to delete template pdf?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertViewForDeleteForms.tag = 502;
    [alertViewForDeleteForms show];
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
         didEditPDFForValue:(id) value{
    currentSelectedPDFTemplateCopy = value;
    QMSDataFormDescEditorViewController *vc = [[QMSDataFormDescEditorViewController alloc] initWithNibName:@"QMSDataFormDescEditorViewController" bundle:nil];
    [vc setPdfTemplateCopy:value];
    [self presentViewController:vc
                       animated:YES completion:nil];
//    UIAlertView *alertViewForNewForms = [[UIAlertView alloc] initWithTitle:[QMSTableViewDataSource _textFromValue:value] message:@"Please Enter New Description" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//    alertViewForNewForms.tag = 503;
//    [alertViewForNewForms setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [alertViewForNewForms show];
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
       didDeletePDFForValue:(id) value{
    currentSelectedPDFTemplateCopy = value;
    NSString *fileName = [QMSTableViewDataSource _textFromValue:value];
    NSString *message = [NSString stringWithFormat:@"This form has not been uploaded to the QMS Watch database. This form and all data for %@.pdf file will be deleted",fileName];
    UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:fileName message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertViewForDeleteForms.tag = 501;
    [alertViewForDeleteForms show];
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
        didEmailPDFForValue:(id) value{
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    BOOL licenseValid = [retriveUserToken boolForKey:@"isLicenceValid"];
    if (licenseValid == NO) {
        [self showLicenceExpiryMessage];
        return;
    }
    [self emailFileForValue:value];
}

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
       didSelectPDFForValue:(QMSPDFTemplateCopy*) value{
    currentSelectedPDFTemplateCopy = value;
    [self launchPDFViewControllerForValue:value];
}

-(void) showLicenceExpiryMessage{
    UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:@"License" message:@"QMS Watch license has expired. Visit QMSWatch.com to renew your license" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    alertViewForDeleteForms.tag = 501;
    [alertViewForDeleteForms show];
}

-(void) launchPDFViewControllerForValue:(QMSPDFTemplateCopy*) value{
    /*
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    // Set the appropriate value in outputItem
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:^(BOOL expired) {
        
    }];
    return;
    */
    //    NSString *filePath = [QMSCoreDataReusableMethod filePathForFileName:[value fileName] withFolderName:PDF_DATAFORMS_FOLDER];
    //    PDFViewController *_pdfViewController = [[PDFViewController alloc] initWithResource:@"testB.pdf"];

    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    BOOL licenseValid = [retriveUserToken boolForKey:@"isLicenceValid"];
    if (licenseValid == NO) {
        [self showLicenceExpiryMessage];
        return;
    }
    
    NSString *filePath = [QMSCoreDataReusableMethod filePathForFileName:[value fileName] withFolderName:PDF_DATAFORMS_FOLDER];
    _pdfViewController = [[PDFViewController alloc] initWithPath:filePath];
//    [_pdfViewController setPdfDataForms:value];
//    _pdfViewController.title = @"Sample PDF";
    [_pdfViewController setTitle:[value valueForKey:@"pdfTemplateDescription"]];
    
    UINavigationController *_navigationController = [self navigationController];
    _navigationController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _navigationController.navigationBar.translucent = NO;
   

    
    if ([[value valueForKey:@"pdfFileEditingDone"] isEqual:@(1)] == NO) {
        UIBarButtonItem * saveBarButtonItem = [self backArrowButtonWithTarget:self
                                                                       action:@selector(savePDFFormFile:)
                                                                    imageName:@"save"];

        
        [_pdfViewController.navigationItem setRightBarButtonItems:@[saveBarButtonItem]];
        
    }
    
    UIBarButtonItem * backBarButtonItem = [self backArrowButtonWithTarget:_pdfViewController.navigationController
                                                                   action:@selector(popViewControllerAnimated:)
                                                                imageName:@"back_btn"];
    
    _pdfViewController.navigationItem.leftBarButtonItem = backBarButtonItem;

    [[self navigationController ] setNavigationBarHidden:NO];

    
    [[self navigationController ] showViewController:_pdfViewController sender:self];

}

- (void)savePDFFormFile:(id)sender {
    
    NSData *savedStaticData = [_pdfViewController.document savedStaticPDFData];
    [QMSCoreDataReusableMethod saveFile:savedStaticData
                                 ofName:[currentSelectedPDFTemplateCopy fileName]
                             intoFolder:PDF_DATAFORMS_FOLDER];
    [currentSelectedPDFTemplateCopy setPdfFileEditingDone:@(1)];
    [QMSCoreDataReusableMethod saveContext];
    
    //    [self removeFromParentViewController];
    //    _pdfViewController = [[PDFViewController alloc] initWithData:savedStaticData];
    //    _pdfViewController.title = @"Saved Static PDF";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Complete" message:@"Now the PDF file is a static version of the previous file, but with the form values added. This static PDF no longer contains forms." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    //    [_navigationController setViewControllers:@[_pdfViewController]];
    [[_pdfViewController navigationController] popViewControllerAnimated:YES];
    
}

-(void) emailFileForValue:(QMSPDFTemplateCopy*) pdfTemplateCopy{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"QMS Watch – completed form"];
//        [mail setMessageBody:@"Here is some main text in the email!" isHTML:NO];
//        [mail setToRecipients:@[@"testingEmail@example.com"]];
        NSData *data = [QMSCoreDataReusableMethod readFileOfName:[pdfTemplateCopy fileName]
                                                      fromFolder:PDF_DATAFORMS_FOLDER];
        [mail addAttachmentData:data
                       mimeType:@"application/pdf"
                       fileName:[pdfTemplateCopy fileName]];
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnHome:(id)sender {
    
   
   
MainMenuViewController *newEnterNameController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:[NSBundle mainBundle]];
   [[self navigationController] pushViewController:newEnterNameController animated:YES];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==alertemail) {
        
        NSLog(@"%@", [alertemail textFieldAtIndex:0].text);
        NSString *mailToperson=[alertemail textFieldAtIndex:0].text;
        
        [self sendMail:reguserToken :mailToperson :dataformid];
    }
    else if (alertView==checkEdit)
    {
        
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            
            alertedit = [[UIAlertView alloc] initWithTitle:@"Please Enter Date/Time and Description"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Done"
                                         otherButtonTitles:nil];
            alertedit.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            
            [alertedit textFieldAtIndex:1].secureTextEntry = NO;
            [alertedit textFieldAtIndex:0].placeholder = @"Date and Time";
            [alertedit textFieldAtIndex:1].placeholder = @"Description";
            
            [alertedit show];
            
            
            
        }
    }
    else if (alertView==alertedit)
    {
        if (buttonIndex==0) {
            
            dateChangestr=[alertedit textFieldAtIndex:0].text;
            descrChangestr=[alertedit textFieldAtIndex:1].text;
            NSLog(@"--datechangestr::%@",dateChangestr);
            NSLog(@"--descrchangestr::%@",descrChangestr);
            
            NSString *  finalDatenDesc = [NSString stringWithFormat:@"%@ : %@", dateChangestr, descrChangestr];
            
            lbl1.text= finalDatenDesc;
            [lbl1 setFont:[UIFont systemFontOfSize:12]];
            [self.view addSubview:lbl1];
            
        }
    }
    else if (alertView==deleteAlertTemp)
    {
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            [self downloadPDFTemplateFile:reguserToken :pdfTempId];
            [lbl1 setHidden:YES];
            
            
            [subViews setHidden:YES];
            
            UIAlertView *tempDeleted=[[UIAlertView alloc]initWithTitle:@"Template Deleted!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [tempDeleted show];
            
        }
    }
    else if (alertView.tag == 404) {
            [self btnPanelDownloadFormTemplate:nil];
        }
    else if (alertView.tag == 500) {
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
        [self createPDFDataFormsWithDiscription:[alertView textFieldAtIndex:0].text];
        }
        //        NSString *  finalDatenDesc = [NSString stringWithFormat:@"%@ : %@", [alertView textFieldAtIndex:0].text, descrChangestr];
    }
    else if (alertView.tag == 501){
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError * error = nil;
            NSString *newFilePath = [QMSCoreDataReusableMethod filePathForFileName:[currentSelectedPDFTemplateCopy fileName] withFolderName:PDF_DATAFORMS_FOLDER];
            if([fileManager removeItemAtPath:newFilePath error:&error] == NO){
                NSLog(@"Error in deleting pdf data froms %@",[error localizedDescription]);
            }
            
            [[QMSCoreDataReusableMethod managedObjectContext] deleteObject:currentSelectedPDFTemplateCopy];
            [QMSCoreDataReusableMethod saveContext];
            [[tableViewDataSource tableView] reloadData];
            
        }
    }
    else if (alertView.tag == 502){
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            [[QMSCoreDataReusableMethod managedObjectContext] deleteObject:currentSelectedPDFTemplate];
            [QMSCoreDataReusableMethod saveContext];
            [self fetchDownloaedPDFTemplatesFromDB];
        }
    }
    else if (alertView.tag == 503){
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            NSString* newDesc = [alertView textFieldAtIndex:0].text;
            [self renamePDFDataFormsFileWithNewDiscription:newDesc];
        }
    }
    else if (alertView.tag == 510){
        if (buttonIndex == 0)
        {
            //Code for Cancel button
        }
        if (buttonIndex == 1)
        {
            [QMSCoreDataReusableMethod saveToUserDefaults:@"isLoggedIn" value:@(0)];
            [self setLogoutBtnLabel];
//            [self redirectToLoginVC];
        }
    }
}

-(BOOL) isNameExist:(NSString*) name{
    BOOL isExist = NO;
    NSFetchRequest *fetchRequest = [QMSPDFTemplateCopy fetchRequestForKey:@"pdfTemplateDescription"
                                                              havingValue:name];
    isExist = [QMSCoreDataReusableMethod countForFetchRequest:fetchRequest] != 0;
    if (isExist == YES) {
        [self showAlertForNewPDFForValue:currentSelectedPDFTemplate withMessage:@"File already exist please enter another Description"];
    }
    return isExist;
}

#pragma mark - Messages to fill the tree nodes and the display array

//This function is used to expand and collapse the node as a response to the ProjectTreeNodeButtonClicked notification
- (void)expandCollapseNode:(NSNotification *)notification
{
    if (flagFrButton == NO) {
        
        flagFrButton = YES;
        [self collapseAll];
        
    }
    else
    {
        [self fillDisplayArray];
        [self.tableView reloadData];
        
        //  NSString *tempTypeButton=@"2"; //temptypeId
        
        
        [self getDownloadPDFTemplateByTemplateTypeId:reguserToken :tempIDForSecW];

        flagFrButton = NO;
    }
}

//These two functions are used to fill the nodes array with the tree nodes
- (void)fillNodesArray
{
    
    nodes=[[NSMutableArray alloc]init];
    
    // temptypeId=[[NSMutableArray alloc]init];
    
    if (maintemplist.count) {
        
        
        
        for (int i=0; i<maintemplist.count; i++) {
            
            TreeViewNode *firstLevelNode1 = [[TreeViewNode alloc]init];
            firstLevelNode1.nodeLevel = 0;
            firstLevelNode1.nodeTag=[maintemplist valueForKey:@"TemplateTypeId"][i];
            firstLevelNode1.nodeObject = [maintemplist valueForKey:@"TemplateTypeName"][i];
            firstLevelNode1.isExpanded = NO;
            firstLevelNode1.nodeChildren = [[self fillChildrenForNode] mutableCopy];
            
            firstLevelNode1.nodeTempTypeID=[maintemplist valueForKey:@"TemplateTypeId"][i];
            [nodes addObject:firstLevelNode1];
            //nodes = [NSMutableArray arrayWithObjects:firstLevelNode1, nil];
            
            NSLog(@"---nodes::%@",nodes);
            
            NSLog(@"---nodes TagID::%@",firstLevelNode1.nodeTempTypeID);
            
            tempIDForSecW=firstLevelNode1.nodeTempTypeID;
            
            //   NSString * tempTypeButton=[NSString stringWithFormat:@"%ld", (long int)[firstLevelNode1 nodeTag]];
            
            // temptypeId=[[maintemplist valueForKey:@"TemplateTypeId"]objectAtIndex:i];
            //   NSLog(@"---temptypeId::%@",temptypeId);
        }
        
    }
}

- (NSArray *)fillChildrenForNode
{
    NSMutableArray *childrenArray;
    
    childrenArray=[[NSMutableArray alloc]init];
    
    NSLog(@"---secondMainTemplate.count::%lu",(unsigned long)secondMainTemplate.count);
    
    
    if (secondMainTemplate.count) {
        
        for (int i=0; i<secondMainTemplate.count; i++) {
            
            TreeViewNode *secondLevelNode1 = [[TreeViewNode alloc]init];
            secondLevelNode1.nodeLevel = 1;
            secondLevelNode1.nodeObject = [secondMainTemplate valueForKey:@"TemplateName"][i];
            
            [childrenArray addObject:secondLevelNode1];
            //nodes = [NSMutableArray arrayWithObjects:firstLevelNode1, nil];
            
            NSLog(@"---childrenArray::%@",childrenArray);
        }
    }
    
    return childrenArray;
}

//This function is used to fill the array that is actually displayed on the table view
- (void)fillDisplayArray
{
    self.displayArray = [[NSMutableArray alloc]init];
    for (TreeViewNode *node in nodes) {
        [self.displayArray addObject:node];
        if (node.isExpanded) {
            [self fillNodeWithChildrenArray:node.nodeChildren];
        }
    }
}

//This function is used to add the children of the expanded node to the display array
- (void)fillNodeWithChildrenArray:(NSArray *)childrenArray
{
    for (TreeViewNode *node in childrenArray) {
        [self.displayArray addObject:node];
        if (node.isExpanded) {
            [self fillNodeWithChildrenArray:node.nodeChildren];
        }
    }
}

//These functions are used to expand and collapse all the nodes just connect them to two buttons and they will work
- (IBAction)expandAll:(id)sender
{
    
    
    NSLog(@"--expandAll-Sender Value::%@",sender);
    
    [self fillNodesArray];
    for (TreeViewNode *treeNode in nodes) {
        treeNode.isExpanded = YES;
    }
    [self fillDisplayArray];
    [self.tableView reloadData];
}

//- (IBAction)collapseAll:(id)sender
//{
//    NSLog(@"--collapseAll-Sender Value::%@",sender);
//
//    for (TreeViewNode *treeNode in nodes) {
//        treeNode.isExpanded = NO;
//    }
//    [self fillDisplayArray];
//    [self.tableView reloadData];
//}

- (void)collapseAll
{
    
    
    for (TreeViewNode *treeNode in nodes) {
        treeNode.isExpanded = NO;
    }
    [self fillDisplayArray];
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.displayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"treeNodeCell";
    static NSString *childCellIdentifier = @"QMSTreenodeTableChildCell";
    TheProjectCell *cell = nil;
    
    TreeViewNode *node = (self.displayArray)[indexPath.row];
    if ([node nodeChildren] != nil){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else{
        cell = [tableView dequeueReusableCellWithIdentifier:childCellIdentifier];
    }
    
    [cell setTreeNode:node];

     cell.cellLabel.text = node.nodeObject;
    
    if (node.isExpanded) {
        
        [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"Open"]];
        [cell.btnSelected setHidden:YES];
        [cell.btnPdfAvailable setHidden:YES];
    }
    else {
        
        [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"Close"]];//
        
        [cell.btnSelected setHidden:NO];
        [cell.btnPdfAvailable setHidden:NO];  //check for Download button for resp index is tapped or not
    }
    
    [cell setNeedsDisplay];
    
    
    [cell.btnSelected addTarget:self action:@selector(callNumber:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Configure the cell...
    cell.btnSelected.tag = indexPath.row;
    
    return cell;
}

- (IBAction)callNumber:(id)sender {
    UIButton* button = sender;
    int index = button.tag;
    
    NSLog(@"---index::%d",index);
    
    NSMutableArray *tempSelectedArr;
    tempSelectedArr =[[NSMutableArray alloc]init];
    
    if (index==0) {
        
    }
    else
    {
        
        if (FlagCheck==NO) {
            
            NSLog(@"Flagg Noo");
            
            FlagCheck=YES;
            
        }
        else{
            
            NSLog(@"Flagg YEss");
            
            if (tempDownloadUrlArr.count) {
                
                
                tempUrl=[NSString stringWithFormat:@"%@",tempDownloadUrlArr[index-1]];
                NSLog(@"--tempUrl::%@",tempUrl);
                
                FlagCheck=NO;
                
            }
        }
    }
    
}





- (void)getDataFormsUploaded:(NSString *)UserToken :(NSString *)pdfDataFormName :(NSString *) pdfTemplateId :(NSString *) PDFBase64
{
    
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    
    // Your JSON data: //{"template":{"Token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","PDFDataFormName":"aatestsadTemplate","PDFTemplateId":"12","PDFBase64":"JVBERi0xLjMNJeLjz9MNCjcgMCBvYmoNPDwvTGluZWFyaXplZCAxL0wgNzk0NS9PIDkvRSAzNTI0"}}
    
    NSString *uploadArray =[NSString stringWithFormat:@"{\"template\":{\"Token\":\"%@\"},{\"PDFDataFormName\":\"%@\"},{\"PDFTemplateId\":\"%@\"},{\"PDFBase64\":\"%@\"}}",reguserToken,pdfDataFormName,pdfTemplateId,PDFBase64];
    NSLog(@"uploadArray=%@", uploadArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [uploadArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",UploadPDFDataForm]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpResponseDownloadForm = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (IBAction)btnDataFormCollectDataTapped:(id)sender {
    
}

- (IBAction)btnFormsMenuTapped:(id)sender {
    [self showMenuSlider:!isShown];
}

- (IBAction)hideSlider:(id)sender {
    [self showMenuSlider:YES];
}

-(void) showMenuSlider:(BOOL) show{
    
    if (isShown != show) {
        if (!isShown)
        {
            [self.sidePanelView setHidden:YES];
            isShown = true;
            [_btnsidePanel setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.sidePanelView setHidden:NO];
            
            
            _sidePanelView.frame=CGRectMake(360.0,0.0,_sidePanelView.frame.size.width,_sidePanelView.frame.size.height);
            
            [UIView animateWithDuration:.5
                             animations:^{
                                 _sidePanelView.frame=CGRectMake(-360.0, 0.0, _sidePanelView.frame.size.width, _sidePanelView.frame.size.height);
                                 _sidePanelView.frame=CGRectMake(0.0, 0.0, _sidePanelView.frame.size.width, _sidePanelView.frame.size.height);
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                 
                             }];
            
            isShown = false;
            [_btnsidePanel setImage:[UIImage imageNamed:@"menu_after_swipe.png"] forState:UIControlStateNormal];
        }
        [overlayView setHidden:isShown];
    }

}


- (IBAction)btnPanelUploadFormData:(id)sender {
    
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UploadFormDataVC *uploadView=[[UploadFormDataVC alloc]initWithNibName:@"UploadFormDataVC" bundle:nil];
    [self.navigationController pushViewController:uploadView animated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (IBAction)btnPanelDownloadFormTemplate:(id)sender {
    
    NSArray *vcArray = [self.navigationController viewControllers];
    __block BOOL isDataFormsExistInArray = NO;
    [vcArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[DownloadFormTemplateVC class]] == YES){
            isDataFormsExistInArray = YES;
        }
    }];
    if (isDataFormsExistInArray == YES) {
        [[self navigationController] popViewControllerAnimated:YES];
    } else{
        DownloadFormTemplateVC *downloadFormTempView=[[DownloadFormTemplateVC alloc]initWithNibName:@"DownloadFormTemplateVC" bundle:nil];
        [self.navigationController pushViewController:downloadFormTempView animated:YES];

    }
}

- (IBAction)btnPanelAbout:(id)sender {
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AboutViewController *aboutView=[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:aboutView animated:YES];
     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

- (IBAction)btnLogout:(id)sender {
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == YES) {
        UIAlertView *alertViewForLogout = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
        alertViewForLogout.tag = 510;
        [alertViewForLogout show];
    } else{
        [self redirectToLoginVC];
    }
}

#pragma mark WS

- (void)editDataFormFromService:(NSString *)UserToken :(NSString *)pdfDataFormId :(NSString *)description
{
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    
    // Your JSON data: //{"template":{"Token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","PDFDataFormId":"12","Description":"This is updated description"}}
    
    NSString *loginArray =[NSString stringWithFormat:@"{\"template\":{\"Token\":\"%@\"},{\"PDFDataFormId\":\"%@\"},{\"Description\":\"%@\"}}",reguserToken,pdfDataFormId,description];
    NSLog(@"editDataForm=%@", loginArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [loginArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",EditPDFDataForm]]];
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




#pragma mark Downloadfrom Templates



#pragma mark Actions

- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDownloadNowTapped:(id)sender {
    
    //for downloading pdf
    //  tempUrl=[NSString stringWithFormat:@"%@",[tempDownloadUrlArr objectAtIndex:indexPath.row]];
    //        NSLog(@"--tempUrl::%@",tempUrl);
    
    
    NSURL *url =[NSURL fileURLWithPath:tempUrl];
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.docController.delegate = self;
    
    BOOL isValid = [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    NSLog(@"Is valid %d",isValid);
    
    //check file is downloded or not
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *tileDirectory = [documentdir stringByAppendingPathComponent:tempUrl];
    NSLog(@"Tile Directory: %@", tileDirectory);
    
}



#pragma mark WS

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
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",EditPDFDataForm]]];
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

//{"token":"69ad957d-e9e5-461e-bc30-51778073307dwbIi6Yu3","subject":"Test","mailTo":"virendradeshmukh@techechelons.com", "dataFormId":"22"}
- (void)sendMail:(NSString *)UserToken :(NSString *)mailTo :(NSString *)dataFormId
{
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    //  {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    // Your JSON data: {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    NSString *tempArray =[NSString stringWithFormat:@"{\"token\":\"%@\",\"mailTo\":\"%@\",\"dataFormId\":\"%@\"}",reguserToken,mailTo,dataFormId];
    NSLog(@"DownloadPDFTemplateByTemplateTypeId=%@", tempArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [tempArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",SendMail]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpMailSend = [[NSMutableData alloc] init];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can not connect to service." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
}

- (void)getDataFormsALlids:(NSString *)UserToken :(NSString *) templateid
{
    // Start showing activity indicator.U
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //retrive userToken
    NSUserDefaults *retriveUserToken = [NSUserDefaults standardUserDefaults];
    reguserToken = [retriveUserToken stringForKey:@"Token"];
    NSLog(@"----regUserToken ::%@",reguserToken);
    
    
    // {"token":"token", "templateId":"34"}
    // Your JSON data: {"template":{"token":"3c2cca0c-4c0e-461c-838a-9c5b6db7162fWCjCHgaz","TemplateTypeId":"3"}}
    NSString *tempArray =[NSString stringWithFormat:@"{\"token\":\"%@\",\"templateId\":\"%@\"}",reguserToken,templateid];
    NSLog(@"DownloadPDFTemplateByTemplateTypeId=%@", tempArray);
    
    
    // Encode the post string.
    NSData *postRequestData = [tempArray dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create a URL request with all the properties (HTTP method, HTTP header).
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] init] ;
    [httpRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",PDFDataFormListByTemplateId]]];
    [httpRequest setHTTPMethod:@"POST"];
    // Commented as it is not needed.
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpRequest setHTTPBody:postRequestData];
    
    // Create URL Connection object and initialize it with URL Request.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
    
    if (connection)
    {
        NSLog(@"Connection successful.");
        httpPdfDataForm = [[NSMutableData alloc] init];
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
    
    [httpResponseDownloadForm setLength:0];
     [httpDownloadTempFile setLength:0];
    [httpPdfDataForm setLength:0];
    [httpMailSend setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpResponseData appendData:data];
    [httpTemplateTypeId appendData:data];
    [httpResponseDownloadForm appendData:data];
     [httpDownloadTempFile appendData:data];
    [httpMailSend appendData:data];
    [httpPdfDataForm appendData:data];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (httpResponseDownloadForm) {
        
        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpResponseDownloadForm length]);
        NSString *strr = [[NSString alloc] initWithData:httpResponseDownloadForm encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
    //    NSError *e = nil;
    //    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpResponseDownloadForm options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpResponseDownloadForm options:NSJSONReadingMutableLeaves error:nil];
        
        
        //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
        
        codeR = [dict[@"d"][@"ResponseCode"] stringValue];
        
        
        if ([codeR isEqualToString:@"200"])
        {
            NSLog(@"--Done");
            
          //  [_tabletreeView setHidden:NO];
            
            secondMainTemplate = [[NSMutableArray alloc]init];
            secondMainTemplate = dict[@"d"][@"Templates"];
            
            
            NSLog(@"--secondMainTemplate::%@",secondMainTemplate);
            
            
            tempName =[secondMainTemplate valueForKey:@"TemplateName"];
            NSLog(@"--tempTypeName::%@",tempName);
            
            tempNameArr=[[NSMutableArray alloc]init];
            tempNameArr=[secondMainTemplate valueForKey:@"TemplateName"];
            
            NSLog(@"--tempNameArr::%@",tempNameArr);
            
            
            tempDownloadUrlArr=[[NSMutableArray alloc]init];
            tempDownloadUrlArr=[secondMainTemplate valueForKey:@"DownloadUrl"];
            
          //  [_tabletreeView reloadData];

        
        
    }
        httpResponseDownloadForm=nil;
    }
    
    if (httpTemplateTypeId)
    {
        
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
            
           // pdfBase64Arr=[[NSMutableArray alloc]init];
           // pdfBase64Arr=[secondMainTemplate valueForKey:@"PDFBase64"];
            
            [self expandAll:nil];
            
            
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
        
        
        
    }
    
    else if (httpDownloadTempFile) {
        
        

        NSLog(@"connectionDidFinishLoading");
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpDownloadTempFile length]);
        NSString *strr = [[NSString alloc] initWithData:httpDownloadTempFile encoding:NSUTF8StringEncoding];
        NSLog(@"strr is: %@",strr);
        
        
        // convert to JSON
        
   //     NSError *e = nil;
    ///    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpDownloadTempFile options:NSJSONReadingAllowFragments error:&e];
        
        
     [self.websubview setHidden:NO];
        
         [_webviewshowpdf setHidden:NO];
        
         [_tabletreeView setHidden:YES];
        
         [self.closebtn setHidden:NO];
        
        [_webviewshowpdf loadData:httpDownloadTempFile MIMEType: @"application/pdf" textEncodingName: @"UTF-8" baseURL:nil];
        
        
        
        httpDownloadTempFile=nil;
    }
else if (httpPdfDataForm)
{
    
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpPdfDataForm length]);
    NSString *strr = [[NSString alloc] initWithData:httpPdfDataForm encoding:NSUTF8StringEncoding];
    NSLog(@"strr is: %@",strr);
    
    
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpPdfDataForm options:NSJSONReadingMutableLeaves error:nil];
    
    
    //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
    
    codeR = [dict[@"d"][@"ResponseCode"] stringValue];
    
  //  NSString *codeResp=[[[dict objectForKey:@"d"]objectForKey:@"DataForms"];
    
    
    
    pdfDataFormID = [[NSMutableArray alloc]init];
    pdfDataFormID = dict[@"d"][@"DataForms"];
    
    
    NSLog(@"--pdfDataFormID::%@",pdfDataFormID);
    
    
    dataformid =[pdfDataFormID valueForKey:@"PDFDataFormId"][0];
    NSLog(@"--dataformid::%@",dataformid);
    
    
    if ([codeR isEqualToString:@"200"])
    {
        NSLog(@"--Done");
     
    }
    else
    {
        NSLog(@"--Nope");
    }
    httpPdfDataForm=nil;
    
}
else if (httpMailSend)
{
    
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[httpMailSend length]);
    NSString *strr = [[NSString alloc] initWithData:httpMailSend encoding:NSUTF8StringEncoding];
    NSLog(@"strr is: %@",strr);
    
    
    // convert to JSON
    
  //  NSError *e = nil;
   // NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: httpMailSend options:NSJSONReadingMutableContainers error:&e];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpMailSend options:NSJSONReadingMutableLeaves error:nil];
    
    
    //d:{"ResponseCode": 200,"Message": "Login successful","Token": "40fff23f-acdb-4247-a029-65d3a912ea95wuGzEHyy"}
    
    codeR = [dict[@"d"][@"ResponseCode"]stringValue] ;
    codeMsg= dict[@"d"][@"Message"];
    
    if ([codeR isEqualToString:@"200"])
    {
        NSLog(@"--Done");
        
        UIAlertView * alertsuccess=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
    else
    {
        NSLog(@"--Nope");
        
        UIAlertView * alertfail=[[UIAlertView alloc]initWithTitle:nil message:codeMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertfail show];
        
    }
    httpMailSend=nil;

    
}
    else if (httpResponseData)
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
            
            
            NSLog(@"--maintemplist::%@",maintemplist);
            
            
            tempTypeName =[maintemplist valueForKey:@"TemplateTypeName"];
            NSLog(@"--tempTypeName::%@",tempTypeName);
            
            
//            //save Temp Type to userdefault for data form
//            NSUserDefaults *saveTempType = [NSUserDefaults standardUserDefaults];
//            [saveTempType setObject:[maintemplist valueForKey:@"TemplateTypeName"] forKey:@"temptypes"];
//            [saveTempType synchronize];
//            
//            
//            //to retrive
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            NSArray *arrayOfImages = [userDefaults objectForKey:@"temptypes"];
//            NSLog(@"--arrayOfTemptypes userdefault:%@",arrayOfImages);
        
            
            
            tempIDvalue=[maintemplist valueForKey:@"TemplateTypeId"];
            NSLog(@"--tempIDvalue::%@",tempIDvalue);
            
//            //save  tempID to userdefault for data form
//            NSUserDefaults *saveTempID = [NSUserDefaults standardUserDefaults];
//            [saveTempID setObject:[maintemplist valueForKey:@"TemplateTypeId"] forKey:@"tempID"];
//            [saveTempID synchronize];
//            
//            
//            //to retrive
//            NSUserDefaults *userDefaultsID = [NSUserDefaults standardUserDefaults];
//            NSArray *arrayOfIds = [userDefaultsID objectForKey:@"tempID"];
//            NSLog(@"--arrayOfIds userdefault:%@",arrayOfIds);
        
            
            [self fillNodesArray];
            [self fillDisplayArray];
            [self.tableView reloadData];
            
        
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

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
    
   [_tabletreeView reloadData];
    
}



#pragma mark TableView delegates

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    
//    return tempNameArr.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 40;
//    
//}
//
//
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CellIdentifier = @"DataFormsCustom";
//    DataFormsCustom *cell = (DataFormsCustom *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DataFormsCustom" owner:self options:nil];
//        for (id currentObject in topLevelObjects) {
//            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
//                cell = (DataFormsCustom *)currentObject;
//                break;
//            }
//        }
//    }
//    
//    
//    [_tabletreeView setFrame:CGRectMake(45 , 124 + (buttonTempTag*17), 289, 160)] ;
//    
//    
//    //to retrive Templates
//    NSUserDefaults *userDefaultsTemp = [NSUserDefaults standardUserDefaults];
//    NSArray *arrayOfTemplates = [userDefaultsTemp objectForKey:@"TemplateName"];
//    NSLog(@"--arrayOfTemplates userdefault:%@",arrayOfTemplates);
//    
//    if (arrayOfTemplates.count) {
//        
//        cell.TempNames.text=[NSString stringWithFormat:@"%@",[arrayOfTemplates objectAtIndex:indexPath.row]];
//        
//        ///New button
//        cell.NewButtons.tag = indexPath.row;
//        [cell.NewButtons addTarget:self action:@selector(NewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    
////    if (secondMainTemplate.count) {
////        
////        tempName =[secondMainTemplate valueForKey:@"TemplateName"];
////        NSLog(@"--tempTypeName in cell::%@",tempName);
////       cell.TempNames.text=[NSString stringWithFormat:@"%@",[tempNameArr objectAtIndex:indexPath.row]];
////    
////        
////        tempUrl=[NSString stringWithFormat:@"%@",[tempDownloadUrlArr objectAtIndex:indexPath.row]];
////        NSLog(@"--tempUrl::%@",tempUrl);
////        
////        
////        
////        ///New button
////         cell.NewButtons.tag = indexPath.row;
////         [cell.NewButtons addTarget:self action:@selector(NewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
////        
////        
////        //check file is downloded or not
////        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
////        NSString *tileDirectory = [documentdir stringByAppendingPathComponent:tempUrl];
////        NSLog(@"Tile Directory: %@", tileDirectory);
////        if (!tileDirectory) {
////          //  [cell.btnFindPdfAvailableInPhone setHidden:NO];
////            
////            
////        }
////    }
//    
//    
//    return cell;
//}
//

-(void)NewButtonTapped:(UIButton*)sender
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
            
            
        }
        
        
    }

    [self getDataFormsALlids:reguserToken :pdfTempId];
    
    
    [arryfornew addObject:@"1"];
    
   
    for (j=0; j<secondMainTemplate.count; j++) {
    
   if (sender.tag == j)
    {
        
        //call webservice for new
        NSLog(@"for Tag 0------NewButtonTapped::%d",j);

        
        NSDateFormatter *formatter;
        NSString        *dateString;
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        
        dateString = [formatter stringFromDate:[NSDate date]];
        
        NSLog(@"--Currunt system date::%@",dateString);
        
       
        
        int xPosition = 69;
        for (int i = 0; i < arryfornew.count; i++) {
             subViews = [[UIView alloc] initWithFrame:CGRectMake(xPosition, 210 + (i*35) , 215, 38)];
            // subViews.backgroundColor =[UIColor lightGrayColor];
            [self.view addSubview:subViews];
         //   xPosition += 40;
            
            
            lbl1 = [[UILabel alloc] init];
           
            [lbl1 setFrame:CGRectMake(71, 210 + (i*35) , 120, 35)];
            lbl1.backgroundColor=[UIColor clearColor];
            lbl1.textColor=[UIColor blackColor];
            lbl1.textAlignment = NSTextAlignmentLeft;
            lbl1.userInteractionEnabled=NO;
            lbl1.text= dateString;
            [lbl1 setFont:[UIFont systemFontOfSize:12]];
            [self.view addSubview:lbl1];
            
            
            
            //for edit
            UIButton*    editbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            [editbutton setFrame:CGRectMake(105 , 5 + (i*1), 32, 30)];  //190,14,38,30
            
            [editbutton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            
            editbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            [editbutton addTarget:self action:@selector(EditbuttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
          //  button.tag=[[arrayOfIds objectAtIndex:i]integerValue];
            
            //  button.tag=i+1;
            
            [subViews addSubview:editbutton];
            
            
            ///For delete Button
            UIButton*    deletebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            [deletebutton setFrame:CGRectMake(140 , 5 + (i*1), 32, 30)];  //190,14,38,30
            
            [deletebutton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            
            deletebutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            [deletebutton addTarget:self action:@selector(DeletebuttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
            [subViews addSubview:deletebutton];
            
            
            ///For email Button
            UIButton*    emailbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            [emailbutton setFrame:CGRectMake(175 , 5 + (i*1), 32, 30)];  //190,14,38,30
            
            [emailbutton setBackgroundImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
            
            emailbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            [emailbutton addTarget:self action:@selector(EmailbuttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [subViews addSubview:emailbutton];

        }
    }
 
    }
}

-(void)EditbuttonPressed:(id)sender
{
    NSLog(@"--EditbuttonPressed");
    
    checkEdit=[[UIAlertView alloc]initWithTitle:nil message:@"Do you want to change date and Time?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [checkEdit show];
    
    

    
 
}

-(void)DeletebuttonPressed:(id)sender
{
    NSLog(@"--DeletebuttonPressed");
 //   int j;
    
    
    
    deleteAlertTemp=[[UIAlertView alloc]initWithTitle:@"Are you sure you want to delete?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [deleteAlertTemp show];
}

-(void)EmailbuttonPressed:(id)sender
{
    NSLog(@"--EmailbuttonPressed");
    
    // webservice for email
    //check for data coneection if yes den allow for email
    //call email webservice
    
    [self testInternetConnection];
    
}


// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            
       //     NSString *dataformid =[[pdfDataFormID valueForKey:@"PDFDataFormId"]objectAtIndex:1];
           NSLog(@"--dataformid::%@",dataformid);
            
           
            alertemail = [[UIAlertView alloc] initWithTitle:@"Please Enter Email Id"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            alertemail.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertemail show];
            
            
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            UIAlertView * alertcheckinternate=[[UIAlertView alloc]initWithTitle:nil message:@"Need Internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertcheckinternate show];
            
        });
    };
    
    [internetReachableFoo startNotifier];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tempSelectedArr;
    tempSelectedArr =[[NSMutableArray alloc]init];
    
    
    
    if (secondMainTemplate.count) {
        
        
        tempUrl=[NSString stringWithFormat:@"%@",tempDownloadUrlArr[indexPath.row]];
        NSLog(@"--tempUrl::%@",tempUrl);
        
        //addobject
        
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

- (UIBarButtonItem*)backArrowButtonWithTarget:(id)target
                                       action:(SEL)action
                                    imageName:(NSString*) imageName{
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return customBarItem;
}

@end

