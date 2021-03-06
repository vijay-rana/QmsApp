//
//  Constants.h
//  QMS
//
//  Created by KBS on 04/03/16.
//  Copyright © 2016 Techechelons. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//@"http://qmswatch.kindlebit.com/API.asmx/AuthenticateUser"]]];UploadPDFDataForm

#define SITE_URL                            @"http://qmswatch.com/"
#define SITE_URLNEW                            @"http://qmswatch2.kindlebit.com/"
#define asmx_Url                            @"API.asmx/"

#define asmx_UrlNEW                            @"API.asmx/"

#define qmsFull_Url                         [SITE_URL stringByAppendingString:asmx_Url]

#define qmsFull_UrlNEW                         [SITE_URLNEW stringByAppendingString:asmx_UrlNEW]


#define DownloadTemplateFile                [qmsFull_Url stringByAppendingString:@"DownloadTemplateFile"]
#define UploadPDFDataForm                [qmsFull_Url stringByAppendingString:@"UploadPDFDataForm"]
#define EditPDFDataForm                [qmsFull_Url stringByAppendingString:@"EditPDFDataForm"]
#define DownloadPDFTemplateByTemplateTypeId                [qmsFull_Url stringByAppendingString:@"DownloadPDFTemplateByTemplateTypeId"]
#define SendMail                [qmsFull_Url stringByAppendingString:@"SendMail"]
#define PDFDataFormListByTemplateId                [qmsFull_Url stringByAppendingString:@"PDFDataFormListByTemplateId"]
#define UploadPDFDataForm                [qmsFull_Url stringByAppendingString:@"UploadPDFDataForm"]
#define DownloadPDFTemplateTypes                [qmsFull_Url stringByAppendingString:@"DownloadPDFTemplateTypes"]
#define UploadPDFDataFormBase64                [qmsFull_Url stringByAppendingString:@"UploadPDFDataFormBase64"]
#define CheckLicenseExpiryDate                [qmsFull_Url stringByAppendingString:@"CheckLicenseExpiryDate"]
#define AuthenticateUser                [qmsFull_Url stringByAppendingString:@"AuthenticateUser"]
#define UploadPDFDataFormBase64                [qmsFull_Url stringByAppendingString:@"UploadPDFDataFormBase64"]

#define CheckListNameByCustomerId                [qmsFull_UrlNEW stringByAppendingString:@"CheckListNameByCustomerId"]
#define CheckListDetailsByCheckListID                [qmsFull_UrlNEW stringByAppendingString:@"CheckListDetailsByCheckListID"]


#endif /* Constants_h */
