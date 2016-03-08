//
//  QMSPDFTemplateCopy.h
//  QMS
//
//  Created by Mac Book Pro on 07/05/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSResource.h"
@interface QMSPDFTemplateCopy : QMSResource

@property (nonatomic, retain) NSString * pdfTemplateDescription;
@property (nonatomic, retain) NSDate * creationDateTime;
@property (nonatomic, retain) NSNumber * pdfTemplateId;
@property (nonatomic, retain) NSNumber * pdfFileEditingDone;

-(NSString*) pdfTemplateCompleteDesc;
-(NSString*) fileName;

@end

@interface QMSPDFTemplateCopy (QMSTableViewDatasourceDisplayObject) <QMSTableViewDatasourceDisplayObject>

@end