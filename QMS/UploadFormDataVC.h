//
//  UploadFormDataVC.h
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"MBProgressHUD.h"
#import"MBProgressHUD.h"
#import "DownloadFromTemp.h"
#import <sqlite3.h>

#import "NSData+Base64.h"

@interface UploadFormDataVC : UIViewController<NSURLConnectionDataDelegate,UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate>
{
    NSMutableData * responseData, *httpResponseData,*httpTemplateTypeId,*httpDownloadTemp, *httpDownloadTempFile, *httpUploadpdf;
    NSString* reguserToken;
    
    
    
    
    NSString* codeR,*tempName,*tempCreatedDate,*tempTypeName,*codeMsg, *tempIDvalue;
    NSMutableArray * maintemplist, *subtemplist,*secondMainTemplate;
    
    NSMutableArray *arrTempName,*arrTempCreateDate, *arrDownloadURl, *arrTempType,*arrTempNamesub;
    NSString *value1,*value2,*value3;
    NSString *templTypeID;
    NSString *tempDownloadUrl;
    NSString *pdfTempId;  NSString *pdfName;
    
    // UIButton *button;
    BOOL flagFrButton;
    NSMutableArray *tempNameArr, *tempDownloadUrlArr ,*tempCreatedDateArr, *tempDownloadDateArr ,* tempTypeArr ,*modifiedDateArr, *isactiveArr,*pdfBase64Arr ,*pdfTemplateIdArr;
    int buttonTempTag;
    NSString* tempUrl;
    
    NSString *base64file;
    
    NSString  *databasePath;
    
    sqlite3 *contactDB;
    
    NSString *pdfnamestr,*pdftypestr, *createddatestr, *downloaddatestr, *updatedatestr, *urlstr, *checkAvailbilitystr, *descstr, *pdfBase64str;
    
    
    NSString *  binaryFile;
    NSData *binaryData;
    NSData *myData;
    
    NSString *tileDirectory;
}
- (IBAction)btnBackTapped:(id)sender;

- (IBAction)btnUploadNowTapped:(id)sender;



@property (strong, nonatomic) IBOutlet UITableView *tabletreeView;

- (void)getDownloadPDFTemplateFromService:(NSString *)UserToken;
- (void)getDownloadPDFTemplateByTemplateTypeId:(NSString *)UserToken :(NSString *)templateTypeid;


@property (retain,nonatomic) UIDocumentInteractionController *docController;


//- (void)downloadPDFTemplate:(NSString *)UserToken :(NSString *)templateTypeid;
- (void)downloadPDFTemplateFile:(NSString *)UserToken :(NSString *)templateTypeid;
@property (strong, nonatomic) IBOutlet UIWebView *webviewshowpdf;


//for upload
///http://14.141.74.147:8047/UploadPDFDataForm
//{"dataForm":{"token":"", "PDFDataFormName":"", "PDFBase64":""}}
- (void)UploadPDFTemplateFile:(NSString *)UserToken :(NSString *)pdfDataformName :(NSString *)pdfBase64;
- (IBAction)btnCloseTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *closebtn;

+ (NSString*)base64forData:(NSData*)theData ;

@end
