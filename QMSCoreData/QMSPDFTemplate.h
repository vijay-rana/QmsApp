//
//  QMSPDFTemplate.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSResource.h"
@interface QMSPDFTemplate : QMSResource

@property (nonatomic, retain) NSNumber * pdfTemplateId;
@property (nonatomic, retain) NSString * pdfTemplateName;
@property (nonatomic, retain) NSNumber * customerId;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSNumber * templateTypeId;
@property (nonatomic, retain) NSNumber * isDownLoaded;

-(void) setDataObjectDictionary:(NSDictionary*) dict;
-(NSArray*) getAllPdfTemplateCopy;
-(NSString*) fileName;
@end


@interface QMSPDFTemplate (QMSGroupedTableViewDatasourceDisplayObject) <QMSGroupedTableViewDatasourceDisplayObject>

@end