

//
//  DownloadFormTemplateVC.h
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"MBProgressHUD.h"
#import "DownloadFromTemp.h"
#import <sqlite3.h>

typedef NS_ENUM(NSInteger, QMSCurrentNetworkCall) {
    kQMSCurrentNetworkCallGetTemplate = 10,
    kQMSCurrentNetworkCallGetPDFTemplate = 11,
    kQMSCurrentNetworkCallDownloadPDF = 13
};

@interface InspectionsViewController : UIViewController<NSURLConnectionDataDelegate,UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate>
{
    NSString* reguserToken;
    NSMutableData *httpResponseData;
    
    NSString* codeR,*tempName,*tempCreatedDate,*tempTypeName,*codeMsg, *tempIDvalue;
    NSMutableArray * maintemplist, *subtemplist,*secondMainTemplate;
    
    NSString *value1,*value2,*value3;
    NSString *templTypeID;
    NSString *tempDownloadUrl;
    
    
    // UIButton *button;
    BOOL flagFrButton;
    NSMutableArray *tempNameArr, *tempDownloadUrlArr ,*tempCreatedDateArr, *tempDownloadDateArr ,* tempTypeArr ,*modifiedDateArr, *isactiveArr,*pdfBase64Arr, *pdfTemplateIdArr;
    int buttonTempTag;
    NSString* tempUrl;
    
    
    NSString *pdfnamestr,*pdftypestr, *createddatestr, *downloaddatestr, *updatedatestr, *urlstr, *checkAvailbilitystr, *descstr, *pdfBase64str;
    
    NSString *tempIDForSecW;
    BOOL flagforcustombtn;
    
}

- (IBAction)btnBackTapped:(id)sender;
- (IBAction)btnDownloadNowTapped:(id)sender;


//- (void)getDownloadPDFTemplateFromService:(NSString *)UserToken;
- (void)getDownloadPDFTemplateByTemplateTypeId:(NSString *)UserToken :(NSString *)templateTypeid;


@property (retain,nonatomic) UIDocumentInteractionController *docController;

//@property (strong, nonatomic) IBOutlet UIWebView *webviewPdf;

//- (void)downloadPDFTemplate:(NSString *)UserToken :(NSString *)templateTypeid; //check pdf is downloaded or not

@end
