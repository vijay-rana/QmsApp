//
//  QMSDataFormDescEditorViewController.m
//  QMS
//
//  Created by Mac Book Pro on 15/05/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSDataFormDescEditorViewController.h"

@interface QMSDataFormDescEditorViewController (){
    IBOutlet UILabel *lblCurrectDesc;
    IBOutlet UITextField *txtDesc;
    IBOutlet UIDatePicker *datePicker;
}

@end

@implementation QMSDataFormDescEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [datePicker setDate:[_pdfTemplateCopy valueForKey:@"creationDateTime"]];
    [txtDesc setText:[_pdfTemplateCopy valueForKey:@"pdfTemplateDescription"]];
    [lblCurrectDesc setText:[_pdfTemplateCopy valueForKey:@"pdfTemplateDescription"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setPdfTemplateCopy:(QMSPDFTemplateCopy *)pdfTemplateCopy{
    _pdfTemplateCopy = pdfTemplateCopy;
    
}

-(IBAction)cancelBtnPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)doneBtnPressed:(id)sender{
    [self renamePDFDataFormsFileWithNewDiscription:txtDesc.text];
}

-(void) renamePDFDataFormsFileWithNewDiscription:(NSString*) desc{
    //Rename in core data as well actual pdf file name.
    if ([desc isEqualToString:[_pdfTemplateCopy valueForKey:@"pdfTemplateDescription"]] == YES || [self isNameExist:desc] == NO) {
        QMSPDFTemplateCopy *pdfTemplateCopy = _pdfTemplateCopy;
        NSString *oldFilePath = [QMSCoreDataReusableMethod filePathForFileName:[pdfTemplateCopy fileName] withFolderName:PDF_DATAFORMS_FOLDER];
        [pdfTemplateCopy setPdfTemplateDescription:desc];
        [pdfTemplateCopy setCreationDateTime:[datePicker date]];
        [QMSCoreDataReusableMethod saveContext];
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError * error = nil;
        NSString *newFilePath = [QMSCoreDataReusableMethod filePathForFileName:[pdfTemplateCopy fileName] withFolderName:PDF_DATAFORMS_FOLDER];
        if([fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error] == NO){
            NSLog(@"Error in renaming pdf data froms %@",[error localizedDescription]);
        }
        [self cancelBtnPressed:nil];
    }
}

-(BOOL) isNameExist:(NSString*) name{
    BOOL isExist = NO;
    NSFetchRequest *fetchRequest = [QMSPDFTemplateCopy fetchRequestForKey:@"pdfTemplateDescription"
                                                              havingValue:name];
    isExist = [QMSCoreDataReusableMethod countForFetchRequest:fetchRequest] != 0;
    
    if (isExist == YES) {
        NSString *message =  @"File already exist please enter another Description";
        UIAlertView *alertViewForNewForms = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertViewForNewForms show];
    }
    return isExist;
}
@end
