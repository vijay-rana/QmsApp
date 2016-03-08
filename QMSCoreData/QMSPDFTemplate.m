//
//  QMSPDFTemplate.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSPDFTemplate.h"


@implementation QMSPDFTemplate

@dynamic pdfTemplateId;
@dynamic pdfTemplateName;
@dynamic customerId;
@dynamic createdBy;
@dynamic isActive;
@dynamic downloadUrl;
@dynamic templateTypeId;
@dynamic isDownLoaded;

-(void) setDataObjectDictionary:(NSDictionary*) dict{
    if (dict != nil && [dict count] > 0) {
        [self setTemplateTypeId:[dict valueForKey:@"TemplateTypeId"]];
        [self setPdfTemplateId:[dict valueForKey:@"PDFTemplateId"]];
        [self setPdfTemplateName:[dict valueForKey:@"TemplateName"]];
        [self setDownloadUrl:[dict valueForKey:@"DownloadUrl"]];
    }
}

+(instancetype) getPersistentObject:(QMSPDFTemplate*) templateObject{
    QMSPDFTemplate *persiObject = [QMSPDFTemplate getPersistentObjectForKey:@"pdfTemplateId" havingValue:[templateObject valueForKey:@"pdfTemplateId"]];
    return persiObject;
}

-(NSArray*) getAllPdfTemplateCopy{
    return [QMSPDFTemplateCopy getPersistentObjectsForKey:@"pdfTemplateId" havingValue:[self valueForKey:@"pdfTemplateId"]];
}

-(NSString*) fileName{
    return [NSString stringWithFormat:@"%@.pdf",[self valueForKey:@"pdfTemplateName"]];
}

@end

@implementation QMSPDFTemplate (QMSGroupedTableViewDatasourceDisplayObject)

-(NSString*) detailLabelText{
    return [self valueForKey:@"pdfTemplateName"];
}

-(NSArray*) rowValueArray{
    return [self getAllPdfTemplateCopy];
}

@end