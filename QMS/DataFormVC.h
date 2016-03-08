//
//  DataFormVC.h
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"MBProgressHUD.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"


@interface DataFormVC : UIViewController<UIScrollViewDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString* reguserToken;
    NSMutableData *httpResponseData ,*httpResponseDownloadForm, *httpDownloadTempFile, *httpMailSend,*httpPdfDataForm;
    
    NSMutableArray * pdfDataFormID,*tempTypeArr,*tempCreatedDateArr,*tempDownloadDateArr,*modifiedDateArr,*isactiveArr;
    
    Reachability *internetReachableFoo;
    /////
   
    NSMutableData *httpTemplateTypeId;
    
    NSString* codeR,*tempName,*tempCreatedDate,*tempTypeName,*codeMsg,*tempIDvalue;
    NSMutableArray * maintemplist, *subtemplist,*secondMainTemplate;
    
    NSMutableArray *arrTempName,*arrTempCreateDate, *arrDownloadURl, *arrTempType,*arrTempNamesub;
    NSString *value1,*value2,*value3;
    NSString *templTypeID;
    NSString *tempDownloadUrl;
    
    
    // UIButton *button;
    BOOL flagFrButton;
    NSMutableArray *tempNameArr, *tempDownloadUrlArr;
    int buttonTempTag;
    NSString* tempUrl;
    
    NSMutableArray *arryfornew;
     NSString *pdfTempId;
    NSMutableArray *pdfTemplateIdArr;
 
    NSArray *arrayOfTempTypes;
    NSString *dataformid;
    
    UIAlertView *alertemail, *checkEdit,*alertedit, *deleteAlertTemp ;
    
    NSString *dateChangestr,*descrChangestr;
    UILabel *lbl1 ;
    UIView * subViews;
    
    NSString *tempIDForSecW;
    
}
- (IBAction)btnDataFormCollectDataTapped:(id)sender;
- (IBAction)btnFormsMenuTapped:(id)sender;



@property (retain, nonatomic) IBOutlet UIButton *btnsidePanel;


@property (strong, nonatomic) IBOutlet UIView *sidePanelView;
- (IBAction)btnPanelUploadFormData:(id)sender;

- (IBAction)btnPanelDownloadFormTemplate:(id)sender;
- (IBAction)btnPanelAbout:(id)sender;

- (void)editDataFormFromService:(NSString *)UserToken :(NSString *)pdfDataFormId :(NSString *)description;




@property (strong, nonatomic) IBOutlet UITableView *tabletreeView;

- (void)getDownloadPDFTemplateFromService:(NSString *)UserToken;
- (void)getDownloadPDFTemplateByTemplateTypeId:(NSString *)UserToken :(NSString *)templateTypeid;


@property (retain,nonatomic) UIDocumentInteractionController *docController;


- (void)getDataFormsUploaded:(NSString *)UserToken :(NSString *)pdfDataFormName :(NSString *) pdfTemplateId :(NSString *) PDFBase64;

@property (strong, nonatomic) IBOutlet UIWebView *webviewshowpdf;
@property (strong, nonatomic) IBOutlet UIButton *closebtn;
@property (strong, nonatomic) IBOutlet UIButton *savebtn;
@property (strong, nonatomic) IBOutlet UIView *websubview;

- (void)getDataFormsALlids:(NSString *)UserToken :(NSString *) templateTypeid;
- (void)sendMail:(NSString *)UserToken :(NSString *) subject :(NSString *)mailTo :(NSString *)dataFormId;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
