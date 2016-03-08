//
//  Constants.h
//  QMS
//
//  Created by KBS on 04/03/16.
//  Copyright © 2016 Techechelons. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
//http://qmswatch.kindlebit.com/API.asmx/UploadPDFDataForm"

#define SITE_URL                            @"http://qmswatch.com/"// @"
#define API_asmx                           @"API.asmx/"
#define API_URL_BASE                       [SITE_URL stringByAppendingString:API_asmx]
#define UploadPDFDataForm                   [API_URL_BASE stringByAppendingString:@"UploadPDFDataForm"]
#define EditPDFDataForm                   [API_URL_BASE stringByAppendingString:@"EditPDFDataForm"]
#define DownloadPDFTemplateByTemplateTypeId                   [API_URL_BASE stringByAppendingString:@"DownloadPDFTemplateByTemplateTypeId"]
#define SendMail                   [API_URL_BASE stringByAppendingString:@"SendMail"]
#define PDFDataFormListByTemplateId                   [API_URL_BASE stringByAppendingString:@"PDFDataFormListByTemplateId"]
#define DownloadTemplateFile                   [API_URL_BASE stringByAppendingString:@"DownloadTemplateFile"]
#define DownloadPDFTemplateTypes                   [API_URL_BASE stringByAppendingString:@"DownloadPDFTemplateTypes"]
#define DownloadPDFTemplateByTemplateTypeId                   [API_URL_BASE stringByAppendingString:@"DownloadPDFTemplateByTemplateTypeId"]
#define CheckLicenseExpiryDate                   [API_URL_BASE stringByAppendingString:@"CheckLicenseExpiryDate"]
#define AuthenticateUser                   [API_URL_BASE stringByAppendingString:@"AuthenticateUser"]
#define UploadPDFDataFormBase64                   [API_URL_BASE stringByAppendingString:@"UploadPDFDataFormBase64"]



#endif /* Constants_h */
